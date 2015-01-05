row_handler = Lights::RowHandler.new

# Shuffles colors periodically
while true
  row_handler.setup_test
  sleep(10)
end
