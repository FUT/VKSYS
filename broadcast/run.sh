ruby server.rb &
echo Server started

for i in 1 2 3 4
do
  shoes client.rb &
  echo Client $i started
done
