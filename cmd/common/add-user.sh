#add new user

user=mikespook
password=false

usage() {
    echo "Usage: $0 [-k \$path] [-u \$user] [-p]"
	echo " -k Path of SSH public key"
	echo " -u User to be created"
	echo " -p Initializing password"
}

while getopts 'k:u:p' o &>> /dev/null; do
    case "$o" in
    k)
        key="$OPTARG";;
	u)
		user="$OPTARG";;
    p)
        password=true;;
    *)
        usage
		exit 3;;
    esac
done

check_root

id $user &>> /dev/null
[ $? -eq 0 ] && echo "User $USER already existed." && exit 2

printf "\n\tSSH Pub-key:\t$key\n"
printf "\tUser name:\t$user:\n"
printf "\tInit passwd:\t$password\n\n"
echo -n "Continue to add? [y|N]: "
read answer
if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
	exit 1
fi

adduser --quiet --disabled-password --gecos "" $user
egrep -i "^admin" /etc/group
[ $? -ne 0 ] && addgroup --system admin
usermod -a -G admin $user
usermod -a -G sudo $user

home=`getent passwd "$user" | cut -d: -f6`
if [ ! -z "$key" ]; then
	mkdir -p $home/.ssh
	if [ -f $key ]; then
		cp $key $home/.ssh/authorized_keys
	else
		wget $key -O $home/.ssh/authorized_keys
	fi
	chown -R $user:$user $home/.ssh
	chmod 700 $home/.ssh
	chmod 600 $home/.ssh/authorized_keys
fi

$password && passwd $user

exit 0
