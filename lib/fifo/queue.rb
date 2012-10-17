module FIFO

  class Queue

    # Public. Constructor logic.
    #
    # name - The String name of the queue.
    # visibility - The Integer visibility of an item in the queue.
    #
    # Returns nothing.
    def initialize(name,visibility=90)
      @name = name
      @visibility = visibility
    end

    # Public. Pop the first entry in the queue and create a payload
    # object from it.
    #
    # options - The Hash of options.
    #   :raw - Return raw queue value instead of a payload.
    #
    # Returns the Payload object if found or nil.
    def pop(options={})
      message = queue.pop

      if message
        if options[:raw]
          payload = message.body
        else
          payload = YAML.load(message.body) 
          payload.queue = self
        end
      end

      payload
    end

    # Push a new entry onto the queue. 
    #
    # args - This can either be a Payload object or a Class or any ruby object
    # including ActiveRecord::Base objects followed by a symbol for a method and optional
    # method arguments. During processing ActiveRecord::Base
    # objects are fetched again from the DB to avoid staleness.
    #
    # Returns nothing.
    def push(*args)
      payload = nil

      if args.first.class == Payload
        payload = args.first
        payload.queue = nil
      else
        payload = Payload.new(*args)
      end

      queue.push(payload.to_yaml)
    end

    # Public: Clear all entries in the queue.
    #
    # Returns nothing.
    def clear
      queue.clear
    end


    private
    
    # Private. Getter method for the queue. Enables opening
    # lazy connections.
    #
    # Returns the Aws::Sqs::Queue object the QueueManager creates.
    def queue
      @queue ||= QueueManager.fetch(@name,@visibility)
    end

  end

end
