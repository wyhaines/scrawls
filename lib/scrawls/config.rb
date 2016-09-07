require 'mime-types'
require 'getoptlong'
require 'scrawls/config/task'
require 'scrawls/config/tasklist'

class SimpleRubyWebServer
  class Config

    def initialize
      @configuration = {}
      @configuration[:docroot] = '.'
      @configuration[:ioengine] = 'nio'
      @configuration[:httpengine] = 'httprecognizer'
      @configuration[:port] = 8080
      @configuration[:host] = '127.0.0.1'

      @meta_configuration = {}
      @meta_configuration[:helptext] = ''
    end

    def [](val)
      @configuration.has_key?(val) ? @configuration[val] : @meta_configuration[val]
    end

    def config
      @configuration
    end

    def meta
      @meta_configuration
    end

    def classname(klass)
      parts = Array === klass ? klass : klass.split(/::/)
      parts.inject(::Object) {|o,n| o.const_get n}
    end

    def parse(parse_cl = true, additional_config = {}, additional_meta_config = {}, additional_tasks = nil)
      @configuration.merge! additional_config
      @meta_configuration.merge! additional_meta_config
      
      tasklist = parse_command_line if parse_cl

      tasklist = merge_task_lists(tasklist, additional_tasks) if additional_tasks

      run_task_list tasklist
    end

    def run_task_list( tasks )
      tasks = tasks.sort

      result = nil
      while tasks.any? do
        new_task = tasks.shift
        result = new_task.call # If any task returns a task list, fall out of execution
        break if TaskList === result
      end

      tasks = merge_task_lists(tasks, result) if TaskList === result # merge any new tasks into the remaining tasks

      run_task_list( tasks ) if tasks.any? # run any remaining tasks
    end

    def merge_task_lists(old_list, new_list)
      ( old_list + new_list ).sort
    end

    def parse_command_line
      call_list = TaskList.new

      opts = GetoptLong.new(
        [ '--help',        '-h', GetoptLong::NO_ARGUMENT],
        [ '--ioengine',    '-i', GetoptLong::REQUIRED_ARGUMENT],
        [ '--httpengine',  '-e', GetoptLong::REQUIRED_ARGUMENT],
        [ '--port',        '-p', GetoptLong::REQUIRED_ARGUMENT],
        [ '--docroot',     '-d', GetoptLong::REQUIRED_ARGUMENT]
      )

      opts.each do |opt, arg|
        case opt
        when '--help'
          exe = File.basename( $PROGRAM_NAME )
          @meta_configuration[:helptext] << <<-EHELP
#{exe} [OPTIONS]

#{exe} is a simple ruby web server.

-h, --help:
  Show this help.

-d DIR, --docroot DIR:
  Provide a specific directory for the docroot for this server.

-i IO_ENGINE, --ioengine IO_ENGINE:
  Tell the webserver which concurrency engine to use. 

-h HTTP_ENGINE, --httpengine HTTP_ENGINE:
  Tell the webserver which concurrency engine to use. 

-p PORT, --port PORT:
  The port for the web server to listen on. If this flag is not used, the web
  server defaults to port 80.

-b HOSTNAME, --bind HOSTNAME:
  The hostname/IP to bind to. This defaults to 127.0.0.1 if it is not provided.

EHELP
          call_list << Task.new(9999) { puts @meta_configuration[:helptext]; exit 0 }
        when '--docroot'
          call_list << Task.new(9000) { @configuration[:docroot] = arg }
        when '--ioengine'
          call_list << Task.new(0) do
            libname = "scrawls/ioengine/#{arg}"
            setup_engine(:ioengine, libname)
          end
        when '--httpengine'
          call_list << Task.new(0) do
            libname = "scrawls/httpengine/#{arg}"
            setup_engine(:httpengine, libname)
          end
        when '--port'
          call_list << Task.new(9000) { @port = arg.to_i != 0 ? arg.to_i : @port }
        when '--bind'
          call_list << Task.new(9000) { @host = arg }
        end
      end

      call_list
    end

    def setup_engine(key, libname)
      require libname
      klass = classname( libname.split(/\//).collect {|s| s.capitalize} )
      @configuration[key] = klass
      @configuration[key].parse_command_line if @configuration[key].respond_to? :parse_command_line
    end

  end
end
