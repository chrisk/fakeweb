class RequestStack < Array
  REQUEST_MAX_COUNT = 30

  def <<(other)
    super
    self.shift if self.size > REQUEST_MAX_COUNT
  end
end
