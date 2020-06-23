class Bag
  def self.with(limit, on_flush)
    bag = new(limit, on_flush)
    yield bag
    bag.flush
  end

  def initialize(limit, on_flush)
    @mux = Mutex.new
    @limit = limit
    @items = []
    @on_flush = on_flush
  end

  def <<(item)
    @mux.synchronize do
      @items << item
    end

    flush if at_limit?
  end

  def at_limit?
    @items.size >= @limit
  end

  def flush
    batch = []
    @mux.synchronize do
      batch = @items
      @items = []
    end

    @on_flush.call(batch) unless batch.empty?
  end
end
