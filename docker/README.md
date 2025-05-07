
```bash
sudo docker pull ubuntu
sudo docker images [shows list of images]
docker run -it -d ubuntu [it = interactive, -d = deaman(should run in background)]
docker ps      [will show all running container]

sudo docker stop [stops the container]
sudo docker ps -a [Shows all (running and not running) containers]

docker exec -it container_id bash [Work with container id] [get the container id using docker ps]
	**Now we can work in the container
	apt-get update
				[sudo command will not found because it is not installed]
	exit			[exit and goes to host operating system, but docker still being running in the background]
	
sudo docker ps
sudo docker stop 		[to check docker running and not running any after stop]
sudo docker kill container_id [Kills container when container being un-responsive]
sudo docker ps -a 	[Chekc all container]
sudo docker rm container_id [removes/deletes the container]
sudo docker rmi image_id [deletes/removes docker image from a system]

## Enter into a container
ll 		[Shows all directory inside a container]
makdir app 	[creates app directory inside the container]
ls		[will show all directories]
exit 		[exits container]
sudo docker ps 	[shows running container]
sudo docker rm -f container_id [to delete running container]

sudo docker run -it -d ubuntu [runs the image]
sudo docker exec -it container_id bash [executes container that will be interact with bash command]
ls          [there will be app directory]

sudo docker commit container_id new_image_name [will create new image named new_image_name]
sudo docker images [to check new image list]
sudo docker run -it -d new_image_name [runs the new_image_name image]
sudo docker exec -ti container_id bash [opens new container]
ls		[will show all directories]

## install apache in a container
sudo docker rm -f $(sudo docker ps -a -q) 	[will remove all container]
sudo docker ps [check there is no container]

sudo docker run -it -d ubuntu 	[will run the ubuntu container]
sudo docker exec -it container_id bash [enters into container]
apt-get update 		[updates the container]
apt-get install apache2	[will install apache]
service apache2 status 	[shows the status of the apache]
service apache2 start	[starts the apache2]
service apache2 status	[shows the status this time it should be running]

exit		[come out from the docker container]
sudo docker ps	[will show container list with id that will be used to commit]
sudo docker commit container_id docker_hub_user_id/image_name(apache)

sudo docker images	[will show the image list]
sudo docker rm -f container_id [removes running container]

sudo docker run -it -p 82:80 -d imagename	[runs the image with port mapping(-p) 82 is OS level port: 80 is container port]
sudo docker exec -it container_id bash [gets into the container]
service  apache2 start		[apache should be started; check from browser]
sudo docker stop container_id [container will be stopped then check the apache from browser to verify]

## Push docker image to docker hub
Create account docker hub account on dockerhub [to push own custom images]
sudo docker login 		[login to the docker hub]
sudo docker push image_name	[the image will be pushed, can check on docker hub server]
```
