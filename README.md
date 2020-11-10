# kubespray – 12 Steps for Installing a Production Ready Kubernetes Cluster

In this project, we will be going through 12 steps starting from setting up vagrant VMs till running the final 
ansible-playbook.

## Step 1: Provision the VMs using Vagrant

First we need to provision the VMs using vagrant.

We will be setting up total 3 VMs (Virtual Machine) with its unique IP -

1. Ansible Node (amaster) - 100.0.0.1 - 2 CPU - 2 GB Memory
2. Kubernetes Master Node (kmaster) - 100.0.0.2 - 2 CPU - 2 GB Memory
3. Kubernetes Worker Node (kworker) - 100.0.0.3 - 2 CPU - 2 GB Memory

Start the vagrant box
 
```bash
vagrant up
```

## Step 2: Update /etc/hosts on all the nodes

After starting the vagrant box you need to update the /etc/hosts file on each node .i.e -amaster, kmaster, kworker

So run the following command on all the three nodes

```bash
vagrant@amaster:~$ sudo nano /etc/hosts
```
Add the following entries in the hosts files of each node (amaster, kmaster, kworker)

```bash
100.0.0.1 amaster.jhooq.com amaster
100.0.0.2 kmaster.jhooq.com kmaster
100.0.0.3 kworker.jhooq.com kworker
```

Your /etc/hosts file should look like this on all the three nodes .i.e. - amaster, kmaster, kworker

```bash
vagrant@amaster:~$ cat /etc/hosts
```

```bash
127.0.0.1	localhost
127.0.1.1	amaster	amaster

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
100.0.0.1 amaster.jhooq.com amaster
100.0.0.2 kmaster.jhooq.com kmaster
100.0.0.3 kworker.jhooq.com kworker
```

## Step 3: Generate SSH key for ansible (only need to run on ansible node .i.e. amaster)

To setup the kubespray smoothly we need to generate the SSH keys for the ansible master(amaster)
nodes and copy the ssh keys to other nodes. So that you do not have to provide username and
password everytime you login/ssh into the other nodes .i.e. - kmaster, kworker

Generate SSH key (during the ssh key generation it might will ask for passphrase so either you create a new
passphrase or leave it empty)

```bash
ssh-keygen -t rsa
```
```bash
Generating public/private rsa key pair.
Enter file in which to save the key (/home/vagrant/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/vagrant/.ssh/id_rsa.
Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:LWGasiSDAqf8eY3pz5swa/nUl2rWc1IFgiPuqFTYsKs vagrant@amaster
The key's randomart image is:
+---[RSA 2048]----+
|          .      |
|   .   . o . .   |
|. . = . + . . .  |
|o+ o o = o     . |
|+.o = = S .   .  |
|. .*.++...  ..   |
|  ooo*.o ..o.    |
| E .oo* .oo+ .   |
|    .oo*+.  +    |
+----[SHA256]-----+
```
## Step 4: Copy SSH key to other nodes .i.e. - kmaster, kworker

In the step-3 we have generated the SSH keys, now we need to copy the SSH keys to other nodes .i.e.
kmaster, kworker

Copy to kmaster node (During the ssh-copy-id it will ask for the other node password, so in case if you
have not set any password then you can supply default password .i.e. vagrant) 

```bash
ssh-copy-id 100.0.0.2
```

```bash
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/vagrant/.ssh/id_rsa.pub"
The authenticity of host '100.0.0.2 (100.0.0.2)' can't be established.
ECDSA key fingerprint is SHA256:uY6GIjFdI9qTC4QYb980QRk+WblJF9cd5glr3SmmL+w.
```
Type “yes” when it asks for - Are you sure you want to continue connecting (yes/no)? yes

```bash
Are you sure you want to continue connecting (yes/no)? yes
```

```bash
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
vagrant@100.0.0.2's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh '100.0.0.2'"
and check to make sure that only the key(s) you wanted were added.
```
Copy to kworker node (During the ssh-copy-id it will ask for the other node password, so in case if you have not set any password then you can supply default password .i.e. vagrant) -

```bash
ssh-copy-id 100.0.0.3
```
```bash
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/vagrant/.ssh/id_rsa.pub"
The authenticity of host '100.0.0.3 (100.0.0.3)' can't be established.
ECDSA key fingerprint is SHA256:uY6GIjFdI9qTC4QYb980QRk+WblJF9cd5glr3SmmL+w.
```
Type “yes” when it asks for - Are you sure you want to continue connecting (yes/no)? yes

```bash
Are you sure you want to continue connecting (yes/no)? yes
```

```bash
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
vagrant@100.0.0.3's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh '100.0.0.3'"
and check to make sure that only the key(s) you wanted were added.
```

## Step 5: Install python3-pip (only need to run on ansible node .i.e. amaster)

Before installing the python3-pip, you need to download and update the package list from the repository.

Run the following command(on all the nodes)

```bash
sudo apt-get update
```

Now you need to install the python3-pip, use the following installation command to install the python3-pip 
(only need to run on ansible node .i.e. amaster)

```bash
sudo apt install python3-pip
```
To proceed with the installation press “y”

```bash
Do you want to continue? [Y/n] y
```
After the installation verify the python and pip version

```bash
python -V
Python 2.7.15+
```

```bash
pip3 -V
pip 9.0.1 from /usr/lib/python3/dist-packages (python 3.6)
```
## Step 6: Clone the kubespray git repo (only need to run on ansible node .i.e. amaster)

In the next step we are going to clone the kubespray. Use the following git command to clone kubespray

```bash
git clone https://github.com/kubernetes-sigs/kubespray.git
```

```bash
Cloning into 'kubespray'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 43626 (delta 0), reused 1 (delta 0), pack-reused 43623
Receiving objects: 100% (43626/43626), 12.72 MiB | 5.18 MiB/s, done.
Resolving deltas: 100% (24242/24242), done.
```
## Step 7: Install kubespray package from “requirement.txt” 
## (only need to run on ansible node .i.e. amaster)

Goto “kubespray” directory

```bash
cd kubespray
```

Install the kubespray packages

```bash
sudo pip3 install -r requirements.txt
```

```bash
The directory '/home/vagrant/.cache/pip/http' or its parent directory is not owned by the current user and the cache has been disabled. Please check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.
The directory '/home/vagrant/.cache/pip' or its parent directory is not owned by the current user and caching wheels has been disabled. check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.
Collecting ansible==2.9.6 (from -r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/ae/b7/c717363f767f7af33d90af9458d5f1e0960db9c2393a6c221c2ce97ad1aa/ansible-2.9.6.tar.gz (14.2MB)
    100% |████████████████████████████████| 14.2MB 123kB/s 
Collecting jinja2==2.11.1 (from -r requirements.txt (line 2))
  Downloading https://files.pythonhosted.org/packages/27/24/4f35961e5c669e96f6559760042a55b9bcfcdb82b9bdb3c8753dbe042e35/Jinja2-2.11.1-py2.py3-none-any.whl (126kB)
    100% |████████████████████████████████| 133kB 4.1MB/s 
Collecting netaddr==0.7.19 (from -r requirements.txt (line 3))
  Downloading https://files.pythonhosted.org/packages/ba/97/ce14451a9fd7bdb5a397abf99b24a1a6bb7a1a440b019bebd2e9a0dbec74/netaddr-0.7.19-py2.py3-none-any.whl (1.6MB)
    100% |████████████████████████████████| 1.6MB 954kB/s 
Collecting pbr==5.4.4 (from -r requirements.txt (line 4))
  Downloading https://files.pythonhosted.org/packages/7a/db/a968fd7beb9fe06901c1841cb25c9ccb666ca1b9a19b114d1bbedf1126fc/pbr-5.4.4-py2.py3-none-any.whl (110kB)
    100% |████████████████████████████████| 112kB 7.0MB/s 
Collecting hvac==0.10.0 (from -r requirements.txt (line 5))
  Downloading https://files.pythonhosted.org/packages/8d/d7/63e63936792a4c85bea3884003b6d502a040242da2d72db01b0ada4bdb28/hvac-0.10.0-py2.py3-none-any.whl (116kB)
    100% |████████████████████████████████| 122kB 6.0MB/s 
Collecting jmespath==0.9.5 (from -r requirements.txt (line 6))
  Downloading https://files.pythonhosted.org/packages/a3/43/1e939e1fcd87b827fe192d0c9fc25b48c5b3368902bfb913de7754b0dc03/jmespath-0.9.5-py2.py3-none-any.whl
Collecting ruamel.yaml==0.16.10 (from -r requirements.txt (line 7))
  Downloading https://files.pythonhosted.org/packages/a6/92/59af3e38227b9cc14520bf1e59516d99ceca53e3b8448094248171e9432b/ruamel.yaml-0.16.10-py2.py3-none-any.whl (111kB)
    100% |████████████████████████████████| 112kB 5.6MB/s 
Requirement already satisfied: PyYAML in /usr/lib/python3/dist-packages (from ansible==2.9.6->-r requirements.txt (line 1))
Requirement already satisfied: cryptography in /usr/lib/python3/dist-packages (from ansible==2.9.6->-r requirements.txt (line 1))
Collecting MarkupSafe>=0.23 (from jinja2==2.11.1->-r requirements.txt (line 2))
  Downloading https://files.pythonhosted.org/packages/b2/5f/23e0023be6bb885d00ffbefad2942bc51a620328ee910f64abe5a8d18dd1/MarkupSafe-1.1.1-cp36-cp36m-manylinux1_x86_64.whl
Requirement already satisfied: six>=1.5.0 in /usr/lib/python3/dist-packages (from hvac==0.10.0->-r requirements.txt (line 5))
Collecting requests>=2.21.0 (from hvac==0.10.0->-r requirements.txt (line 5))
  Downloading https://files.pythonhosted.org/packages/1a/70/1935c770cb3be6e3a8b78ced23d7e0f3b187f5cbfab4749523ed65d7c9b1/requests-2.23.0-py2.py3-none-any.whl (58kB)
    100% |████████████████████████████████| 61kB 6.9MB/s 
Collecting ruamel.yaml.clib>=0.1.2; platform_python_implementation == "CPython" and python_version &lt; "3.9" (from ruamel.yaml==0.16.10->-r requirements.txt (line 7))
  Downloading https://files.pythonhosted.org/packages/53/77/4bcd63f362bcb6c8f4f06253c11f9772f64189bf08cf3f40c5ccbda9e561/ruamel.yaml.clib-0.2.0-cp36-cp36m-manylinux1_x86_64.whl (548kB)
    100% |████████████████████████████████| 552kB 2.5MB/s 
Requirement already satisfied: certifi>=2017.4.17 in /usr/lib/python3/dist-packages (from requests>=2.21.0->hvac==0.10.0->-r requirements.txt (line 5))
Requirement already satisfied: idna&lt;3,>=2.5 in /usr/lib/python3/dist-packages (from requests>=2.21.0->hvac==0.10.0->-r requirements.txt (line 5))
Requirement already satisfied: urllib3!=1.25.0,!=1.25.1,&lt;1.26,>=1.21.1 in /usr/lib/python3/dist-packages (from requests>=2.21.0->hvac==0.10.0->-r requirements.txt (line 5))
Requirement already satisfied: chardet&lt;4,>=3.0.2 in /usr/lib/python3/dist-packages (from requests>=2.21.0->hvac==0.10.0->-r requirements.txt (line 5))
Installing collected packages: MarkupSafe, jinja2, ansible, netaddr, pbr, requests, hvac, jmespath, ruamel.yaml.clib, ruamel.yaml
  Running setup.py install for ansible ... done
  Found existing installation: requests 2.18.4
    Not uninstalling requests at /usr/lib/python3/dist-packages, outside environment /usr
Successfully installed MarkupSafe-1.1.1 ansible-2.9.6 hvac-0.10.0 jinja2-2.11.1 jmespath-0.9.5 netaddr-0.7.19 pbr-5.4.4 requests-2.23.0 ruamel.yaml-0.16.10 ruamel.yaml.clib-0.2.0
```

## Step 8: Copy inventory file to current users (only need to run on ansible node .i.e. amaster)

Now we need to copy the inventory file to current user using the following command

```bash
cp -rfp inventory/sample inventory/mycluster
```

## Step 9: Prepare host.yml for kubespray (only need to run on ansible node .i.e. amaster)
This step is little trivial because we need to update host.yml with the nodes IP.

Now we are going to declare a variable “IPS” for storing the IP address of other nodes .i.e. kmaster(100.0.0.2), kworker(100.0.0.3)
```bash
declare -a IPS=(100.0.0.2 100.0.0.3)
```
```bash
CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```
```bash
DEBUG: Adding group all
DEBUG: Adding group kube-master
DEBUG: Adding group kube-node
DEBUG: Adding group etcd
DEBUG: Adding group k8s-cluster
DEBUG: Adding group calico-rr
DEBUG: adding host node1 to group all
DEBUG: adding host node2 to group all
DEBUG: adding host node1 to group etcd
DEBUG: adding host node1 to group kube-master
DEBUG: adding host node2 to group kube-master
DEBUG: adding host node1 to group kube-node
DEBUG: adding host node2 to group kube-node
```
After running the above commands do verify the hosts.yml and it should be like -
```bash
vi inventory/mycluster/hosts.yml
```
```bash
all:
  hosts:
    node1:
      ansible_host: 100.0.0.2
      ip: 100.0.0.2
      access_ip: 100.0.0.2
    node2:
      ansible_host: 100.0.0.3
      ip: 100.0.0.3
      access_ip: 100.0.0.3
  children:
    kube-master:
      hosts:
        node1:
        node2:
    kube-node:
      hosts:
        node1:
        node2:
    etcd:
      hosts:
        node1:
    k8s-cluster:
      children:
        kube-master:
        kube-node:
    calico-rr:
      hosts: {}
```
## Step 10: Run the ansible-playbook on ansible node .i.e. - amaster (only need to run on ansible node .i.e. amaster)
Now we have done all the prerequisite for running the ansible-playbook.

Use the following ansible-playbook command to begin the installation

```bash
ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml
```
Running ansible playbook takes little time because it depends on the network bandwidth also.

```bash
During playbook run if you face an error “ansible_memtotal_mb >= minimal_master_memory_mb”, please refer to - How to fix – ansible_memtotal_mb >= minimal_master_memory_mb
```

##Step 11: Install kubectl on kubernetes master .i.e. - kmaster (only need to run on kuebernets node .i.e. kmaster)
Now you need to log into the kubernetes master .i.e. kmaster and download the kubectl onto it.
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
```
```bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 41.9M  100 41.9M    0     0  5893k      0  0:00:07  0:00:07 --:--:-- 5962k
```
Now we need to copy the admin.conf file to .kube
```bash
sudo cp /etc/kubernetes/admin.conf /home/vagrant/config
```
```bash
mkdir .kube
```
```bash
mv config .kube/
```
```bash
sudo chown $(id -u):$(id -g ) $HOME/.kube/config
```
```bash
Check the kubectl version after installation
```
```bash
kubectl version
```
```bash
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.2", GitCommit:"52c56ce7a8272c798dbc29846288d7cd9fbae032", GitTreeState:"clean", BuildDate:"2020-04-16T11:56:40Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.2", GitCommit:"52c56ce7a8272c798dbc29846288d7cd9fbae032", GitTreeState:"clean", BuildDate:"2020-04-16T11:48:36Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
```
## Step 12: Verify the kubernetes nodes
Now we have done all the required steps for the installing kubernetes using kubespray.

Lets check the nodes status in out final step

```bash
kubectl get nodes
```
```bash
NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    master   13m   v1.18.2
node2   Ready    master   13m   v1.18.2
```
