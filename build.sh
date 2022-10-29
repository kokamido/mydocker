echo -n Password: 
read -s password
docker build -t $1:$2 --build-arg passw=$password .