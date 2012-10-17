module FIFO

  class Payload
    attr_accessor :queue
    attr_reader :attempts

    # Public. Create a payload with an object a method of that
    # object and optional arguments for that method.
    #
    # object - The Object the payload carries.
    # method - The Symbol method name for the object.
    # args - The optional array of arguments for the method.
    #
    # Returns nothing.
    # Raises ArgumentError if object or method aren't present.
    def initialize(object,method,*args)
      raise ArgumentError, "object and method required" unless object && method

      @attempts = 1
      @object = object.is_a?(Class) ? 
                  object.to_s.split("::").last :
                  object.to_yaml 
      @method = method
      @arguments = args
    end

    # Public. Call the method on the carried object with
    # the carried arguments. If the carried object is an
    # ActiveRecord::Base object, reload it from the db
    # to get a fresh state.
    #
    # Returns the result of the method call on the object.
    def process
      if is_object_yaml?
        object = YAML.load(@object)

        if object.is_a? ActiveRecord::Base
          object = object.class.find object.id 
        end
      else
        object = Object.const_get(@object)
      end

      object.send(@method.to_sym,*@arguments)
    end

    # Public. Mark the instance as failed by increaseing
    # the number of attempts to process it.
    #
    # Returns the Integer number of attempts used.
    def failed
      @attempts += 1
    end

    # Public. Add the payload back onto the queue.
    #
    def retry
      failed
      queue.push self
    end

    # Public. Override to_s for a loggable output.
    #
    # Returns the String form of the Payload.
    def to_s
      output = ""

      if is_object_yaml?
        object = YAML.load(@object)
        output << object.class.name 
      else
        output << Object.const_get(@object).name
      end

      output << " :#{@method} #{@arguments.join("|")}"
      output
    end


    private 

    # Private. Test if the object is a ruby object in YAML.
    #
    # Returns the Boolean value of the test.
    def is_object_yaml?
      @object.start_with? "--- "
    end

  end

end
