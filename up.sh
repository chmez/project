#/bin/sh

CONTAINER_ID=$(docker ps -a -q --filter="name=chmez_github")

if [ $CONTAINER_ID ]
  then
    echo "Deleting container..."
    docker stop $CONTAINER_ID
    docker rm chmez_github
fi

docker build -t chmez/ubuntu:latest .
docker run --net=host -d -i -t --name chmez_github chmez/ubuntu:latest

docker cp 000-default.conf chmez_github:/etc/apache2/sites-available
docker exec -it chmez_github a2enmod rewrite
docker exec -it chmez_github a2enmod headers
docker exec -it chmez_github service apache2 start

docker exec -it chmez_github usermod -d /usr/lib/mysql mysql
docker exec -it chmez_github service mysql start

docker cp project chmez_github:/var/www/html/profiles
docker exec -it chmez_github mkdir profiles/project/themes
docker exec -it chmez_github drush dl bootstrap --destination=profiles/project/themes

docker exec -it chmez_github drush si project --db-url=mysql://root:root@localhost:3306/drupal --account-name=root --account-pass=root --account-mail=admin@example.com --locale=uk --site-name="My Project" --site-mail=admin@example.com -y

docker exec -it chmez_github chown -R www-data:www-data sites/default/files

docker exec -it chmez_github drush cr