module FIFO

  class QueueManager

    # Public. Setup AWS credentials and connection_mode for the service.
    # 
    # aws_access_id - The String AWS access id.
    # aws_secret_key - The String AWS secret key.
    # connection_mode - The Symbol for threading options - 
    #                   :single,:per_thread,:per_request. 
    #                   See: https://github.com/appoxy/aws/ (default: :single)
    #
    def self.setup(aws_access_id,aws_secret_key,connection_mode=:single)
      @aws_access_id = aws_access_id
      @aws_secret_key = aws_secret_key
      @connection_mode = connection_mode
    end
      
    # Public. Open a connection and fetch an Aws::Sqs::Queue.
    #
    # Returns the Aws::Sqs::Queue.
    def self.fetch(name,visibility)
      Aws::Sqs::Queue.create(sqs,name,true,visibility)
    end


    private

    # Private: Getter method for Aws::Sqs object. Enables
    # lazily creating an SqsInterface.
    #
    # Returns the Aws::Sqs.
    def self.sqs
      @sqs ||= Aws::Sqs.new(
                @aws_access_id,
                @aws_secret_key,
                {:connection_mode => @connection_mode})
    end

  end

end
