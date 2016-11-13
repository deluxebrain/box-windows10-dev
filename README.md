# Packer / Vagrant Windows dev box bootstrapper

## Basic setup

Go head and install _Packer_, _Vagrant_, _VirtualBox or VMWare_ in the usual manner for you platform.

### Vagrant

1.  vagrant-vnware-fusion plugin

    If using vmware fusion you will need to install the vmware fusion vagrant plugin and associated license.

    Note this is a licensed product - separate to the actual VMWare fustion software.

    ```sh
    vagrant plugin install vagrant-vmware-fusion
    vagrant plugin license vagrant-vmware-fusion <path_to_license>
    ```

2.  Winrm

    Required for Windows guests

    ```sh
    vagrant plugin install vagrant-winrm
    ```

## Vagrant setup

Note of these steps are strictly necessary but form good housekeeping practices for containing all vagrant, packer and hypervisor large files out of your home directory

1.  ISO's and images

    Create directory structure to hold ISOs and hypervisor/vagrant images outside of specific repositories. Note the use of the `/var` directory - this is intended to be mounted on the non-system disk.

    ```sh
    /var/media/images/vagrant     # vagrant boxes
    /var/media/images/virtualbox  # raw virtual box images
    /var/media/images/vmware      # raw vmware fusion images
    /var/media/iso                # iso images
    ```

2.  Home and cache

    The vagrant `home` directory is used, amongst other things, to store box images. By default this is located in the user home directory - but it can get rather large and hence needs moving out. Similarly, we need somewhere sensible to store vmware/vbox images.

    By default the vmware  provider will clone the vm into the `.vagrant` directory relative to the location of the `Vagrantfile`.
    This can be overriden with the `VAGRANT_VMWARE_CLONE_DIRECTORY` environment variable. Note this variable does not need to be unique per project.

    ```sh
    /var/vagrant/home
    /var/vagrant/vmware-clone
    ```

    These are wired up using the following environment variables:

    ```sh
    export VAGRANT_HOME=/var/vagrant/home
    export VAGRANT_VMWARE_CLONE_DIRECTORY=/var/vagrant/vmware-clone
    ```

## OS installation images

Whatever edition you use, download to your `/var/media/iso` directory to keep this out of your home directory and git repositories.

Note you'll also need to create the sha1 checksum of your ISO images. For example:

```sh
openssl sha1 <iso_path>
```

This can then be passed to packer as a variable, or embedded directly in the packer configuration file.

### Licensing

Whatever edition you use, you will need to setup the `Autounattend` file accordingly. It is currently setup with no license (to suppose the trial edition). Look at the comments in the file to see how to set this up for specific licensing conditions.

#### Using a pro edition

Ideally get yourself an MSDN subscription and download whatever images you need from there. Alternatively, there _was_ the Microsoft Tech Bench site that contained an archive of all OS images - however, that appears to have been taken down. So for now - it looks like the only option is to download the latest image for the current Windows OS from the Microsoft software download site. You'll want the `N` edition (for Europe). Whichever approach you take - obviously you need to go out and buy yourself a license key.

#### Enterprise trial edition

A trial of the Enterprise edition of Windows 10 can be downloaded from here: <https://www.microsoft.com/en-GB/evalcenter/evaluate-windows-10-enterprise>. This has the advantage that it can be installed without providing any license keys at time of installation.

#### Windows 10 development environment virtual machines

Microsoft make a Windows 10 virtual machine available (both as 3 month trial and a licensed edition. This can be downloaded from here: <https://developer.microsoft.com/en-us/windows/downloads/virtual-machines>.  Note - this distributed as hypervisor specific machine images, and hence will need additional setup with Packer.

### Media Creation Tool

The Microsoft Media Creation tool is a client app that manages the creation of OS images. _However_ these images _cannot_ be analysed with the `DISM` tool. Thats fine in most cases - but if you need to inspect the image for some reason then download the ISO directly from the Microsoft software download site.

## Creating the Vagrant box image

The packer build pipeline automatically runs in all available updates. Hence - its worth re-running the pipeline when major updates are available.

1.  Run packer to create the box image

    ```sh
    packer build windows_10_basebox.json
    ```

    To build out only a particular image, use the `only` flag. Also shown is an example of passing in a variable.

    ```sh
    packer build --only vmware-iso \
         --var iso_url="<iso_path>" \
        windows_10_basebox.json
    ```

2.  Add the box to vagrant

    ```sh
    vagrant box add --name windows_10_basebox /var/media/vagrant/vmware/windows_10_basebox.box
    vagrant box list
    vagrant box remove <name> # to remove, if and when required
    ```

    Repeat for box box images. Note - you can use the same same (it is unique on name and provider)

## Vagrantfile

Make any environment specific changes to the Vagrantfile.

To show the number of logical cores on the host box

```sh
sysctl -n hw.ncpu
```

## Basic Vagrant usage

```sh
vagrant up --provider vmware_fusion # virtualbox
vagrant suspend
vagrant resume
vagrant reload # use if changes made to the Vagrantfile
vagrant halt # bring back up with a vagrant up
vagrant destroy
vagrant rdp  # connect to instance using rdp
```

NOTE that the vagrant up step does a full provision of the development box (installation of Visual Studio, etc). This will take result on the box rebooting one or more times. Vagrant doesn't like the image rebooting outside of its control and will report an error when this happens. However - the installation will continue normally. Progress can then be monitored directly on the virual machine.

## Running in changes to the Vagrantfile

```sh
vagrant reload
```

## Running in changes to provisioners

```sh
vagrant reload --provision
```

## Managing running Vagrant instances

Show state of all active Vagrant environments for the current user.

```sh
vagrant global-status
```

### Connecting to the running instance

It is recommended that you use rdp / ssh / whatever to connect to your running instances. I.e. fire them up headless and then use remote connectivity tooling to connect to the instances. However, if you want to share folders between your host and guest machine, you will need to vagrant up the image with a gui and then use the folder sharing mechanisms of your hypervisor.

## Configuring Packer for Windows build

### Configuring the autounattend.xml file

#### Prequisites

1.  DISM ( Windows )

    Deployment Image Servicing and Management (DISM.exe) is a command-line tool to examining Windows images. 
    Installed as part of the Windows Assessment and Deployment Kit

    ```shell
    choco install windows-adk
    ```

2.  Windows installation media in ISO format

    Note that Windows ISO's created using the Media Creation Tool are not compatible with the `DISM` tool.
    Instead - obtain the installation media from the Microsoft software download site. 

#### Extract Windows image metadata required by Packer config

This is required by the `<ImageIstall><OSImage><InstallFrom><MetaData>` element of the `autounattend.xml` file.

Mount the iso associated with the Windows image and locate the _Windows Imaging Format_ ( `.wim` file ) that contains the image metadata.
For Windows 10 this appears to be the `install.wim` file in the root level `sources` directory within the mounted iso.

Examine the `wim` file using the `DSIM` tool as follows:

```shell
dism /Get-WinInfo /WimFile:install.wim
```

This will yield the image names contained in the iso file, for example:

```shell
Index : 1
Name : Windows 10 Pro
Description : ...
Size : ...
```

#### Time-zone information

Use the following command from a Windows box to list timezone strings:

```shell
tzutil /l
```

To find the currently installed timezone use:

```shell
tzutil /g
```

e.g. `GMT Standard Time`

This gives the following configuration in the `Autounattend.xml` file to install UTC:

```shell
<TimeZone>UTC</TimeZone>
```

## Manual provisioning

### Personalization

1.  Ubuntu for Windows

    Run `bash` from a privilegded commmand prompt.

## Bash for Windows

1.  Install mintty 

2.  Add machine name to /etc/hosts

    `sudo`ing on Bash leads to `unable to resolve host MACHINENAME`

    Fix by addin editing your `/etc/hosts/ file`

    ```sh
    127.0.0.1 localhost MACHINENAME
    ```

### Baking off the vagrant box

TODO

## Notes

### Installing Bash for Windows

The installation steps for installing the WLS are to enable developer mode, then download and install Ubuntu for Windows.

The first step is performed as part of the base packer build. However, the second step does not complete successfully when performed under packer. General reasons of winrm substandard for the remote execution of privilegded operations. This is then left as a manual step performed by the user post vagrant up.

The command to install Ubuntu for Windows is as follows, using the `lxrun` application:

```sh
lxrun/exe /install /y
```

Shame it doesnt work unattended.

### File synchronization between vagrant host and guest

Ideally Vagrant would use rsync over ssh for host/guest file sharing. It is possible to get a hacked up version of this running, but the limitation of the windows guest make this not worth persuing.

1.  Inability on Windows to run sshd as a daemon that starts on machine boot

2.  Lack of chroot and associated tooling to secure the sshd server

The alternatives then for a Windows guest and unknown host are to use the hypervisor specfic file sharing mechanisms. Note, in the case of Windows host, Windows guest there are more options (e.g. SMB). Theoretically with a \*nix host and Windows guest NFS should work. It doesn't.

#### Steps to setup rsync over ssh using WSL

-   Generate ssh host keys using `sudo dpkg-reconfigure openssh-server`
-   Alternatively, just reinstall it, which creates the keys
    -   `sudo apt-get remove openssh-server`
    -   `sudo apt-get install openssh-server`
-   Setup `ssshd` config
    -   `sudo vim /etc/ssh/sshd_config`
    -   Set `UsePrivilegeSeparation` to `no` (as WSL doesnt support the `chroot` syscall)
    -   Set `PasswordAuthentication` to `no` or `yes` depdending on if you want to use passwords or keys
-   Edit the sudoers files to allow passwordless esclated access to sshd (i.e. to be able to sudo it without a password)
    -   `sudo visudo`
    -   Add `$USER ALL = (root) NOPASSWD: /usr/sbin/sshd -D` setting USER to your user (e.g. vagrant)
-   Setup the firewall
-   Somehow get the sshd server to start at system boot (hint - you cant)
