# Packer / Vagrant Windows dev box bootstrapper

## Basic setup

### Vagrant

1.  vagrant-vnware-fusion plugin

    Note this is a licensed product - separate to the actual VMWare fustion software.

    ```sh
    vagrant plugin install vagrant-vmware-fusion
    vagrant plugin license vagrant-vmware-fusion <path_to_license>
    ```

## Vagrant setup

1.  ISO's and images

    Create directory structure to hold ISOs and hypervisor/vagrant images outside of specific repositories. Note the use of the `/var` directory - this is intended to be mounted on the non-system disk.

    ```sh
    /var/media/images/vagrant     # vagrant boxes
    /var/media/images/vbox        # raw virtual box images
    /var/media/images/fusion      # raw vmware fusion images
    /var/media/iso                # iso images
    ```

2.  Home and cache

    The vagrant _home_ directory is used, amongst other things, to store box images. By default this is located in the user home directory - but it can get rather large and hence needs moving out. Similarly, we need somewhere sensible to store vmware images.

    By default the VMWare provider will clone the vm into the `.vagrant` directory relative to the location of the `Vagrantfile`.
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

### Using a pro edition

Ideally get yourself an MSDN subscription and download whatever images you need from there. Alternatively, there _was_ the Microsoft Tech Bench site that contained an archive of all OS images - however, that appears to have been taken down. So for now - it looks like the only option is to download the latest image for the current Windows OS from the Microsoft software download site. You'll want the `N` edition (for Europe). Whichever approach you take - obviously you need to go out and buy yourself a license key.

### Enterprise trial edition

A trial of the Enterprise edition of Windows 10 can be downloaded from here: <https://www.microsoft.com/en-GB/evalcenter/evaluate-windows-10-enterprise>. This has the advantage that it can be installed without providing any license keys at time of installation.

### Media Creation Tool

The Microsoft Media Creation tool is a client app that manages the creation of OS images. _However_ these images _cannot_ be analysed with the `DISM` tool. Thats fine in most cases - but if you need to inspect the image for some reason then download the ISO directly from the Microsoft software download site.

## Creating the Vagrant box image

The packer build pipeline automatically runs in all available updates. Hence - its worth re-running the pipeline when major updates are available.

1.  Run packer to create the box image

    ```sh
    packer build --only vmware-iso \
      --var iso_url="<iso_path>" \
      packer.json
    ```

2.  Add the box to vagrant

        ```sh
        vagrant box add /var/media/images/vagrant/macOS_10_12_sierra_vmware.box --name macOS_10_12_sierra_vmware
        vagrant box list
        vagrant box remove <name> # to remove, if and when required
        ```

## Vagrantfile

Make any environment specific changes to the Vagrantfile.

To show the number of logical cores on the host box

```sh
sysctl -n hw.ncpu
```

## Basic Vagrant usage

```sh
vagrant up
vagrant suspend
vagrant resume
vagrant reload # use if changes made to the Vagrantfile
vagrant halt # bring back up with a vagrant up
vagrant destroy
```

## Managing running Vagrant instances

Show state of all active Vagrant environments for the current user.

```sh
vagrant global-status
```

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
