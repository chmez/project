#/bin/sh

sudo rm -rf htdocs
mkdir -p htdocs/profiles
cp -r project htdocs/profiles

CONTAINER_ID=$(docker ps -a -q --filter="name=chmez_github")

if [ $CONTAINER_ID ]
  then
    echo "Deleting container..."
    docker stop $CONTAINER_ID
    docker rm chmez_github
fi

docker build -t chmez/ubuntu:latest .
docker run --net=host -d -i -t -v $(pwd)/htdocs:/var/www/html --name chmez_github chmez/ubuntu:latest

docker exec -it chmez_github service apache2 start
docker exec -it chmez_github service mysql start

cd htdocs
cp ../*.make.yml .

docker exec -it chmez_github drush make profile.make.yml --prepare-install --overwrite -y

rm *.make.yml
cd ..

docker exec -it chmez_github chown -R www-data:www-data sites/default
docker exec -it chmez_github drush si project --db-url=mysql://root:root@localhost:3306/drupal --account-name=root --account-pass=root --account-mail=admin@example.com --locale=uk --site-name="My Project" --site-mail=admin@example.com -y

docker exec -it chmez_github chown -R www-data:www-data sites/default/files
docker exec -it chmez_github drush cr