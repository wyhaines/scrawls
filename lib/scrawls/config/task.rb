class SimpleRubyWebServer
  class Config
    class Task
      include Comparable

      attr_accessor :order, :task

      def initialize(order = 0, &task)
        @order = order
        @task = task
      end

      def <=>(another_task)
        if @order < another_task.order
          -1
        elsif @order > another_task.order
          1
        else
          if @task.to_s < another_task.task.to_s
            -1
          elsif @task.to_s > another_task.task.to_s
            1
          else
            0
          end
        end
      end

      def call(*args)
        @task.call(*args) if @task
      end

    end
  end
end
