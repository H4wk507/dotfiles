# Backups

Backups, done right, require a lot of configuration. Encryption, compression, deduplication, healthchecks, online and offline storage, and so on.
With that many steps it is easy to miss something, and some things cannot be scripted and can only be clicked through in the GUI (at least on macOS).
That's why I'm writing this README. To have a simple, easy-to-follow guide to setting up backups on macOS and save future me from the pain.
The guide follows a macOS configuration, but the steps are basically the same on Linux, where they are even easier.

We will configure two types of backups: online, in the cloud, and offline, on an external hard drive.
The tool we use is borgbackup, a simple, UNIX-like tool that is battle-tested for this job.
It handles encryption and automatically compresses and deduplicates archives.

## Cloud backup

We start with the cloud backup. It is harder than the offline one, as it requires a server, but once we have
it, the offline configuration is just a couple of lines of config.

We need a cloud disk, ideally with a good storage/price ratio. Other than that, the only metric we care about is
uptime. Encryption will be done locally anyway.

A good pick is Hetzner Storage Box. It costs €3.20 per month for 1TB with an option to upgrade, and also gives
you 10 snapshot slots.

Once you have bought the server of your choice, generate and add an SSH key pair for secure communication with it:

```bash
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519_borg_hetzner -C "borg-backup@$(hostname -s) $(date +%Y-%m-%d)" -N ""
```

Give it a descriptive name and a comment, so you will know later what it is used for (I have lost count of how many times I forgot which SSH key is for what :D).
Notice the `-N ""` flag. We are not setting a passphrase on the SSH key. It will be sitting in plaintext on the filesystem. That is intended,
as the backup cron job will be running in the background, and can't decrypt the private key by itself :D. Later, we will restrict that SSH key
on the server to only the `borg serve` command, so a leaked private key won't be able to delete our backups.

Test if you are able to connect to the server with SSH.

```bash
ssh -i ~/.ssh/id_ed25519_borg_hetzner -p 23 u672410@u672410.your-storagebox.de
```

### Borgmatic

Borgmatic is a wrapper script around borg. Instead of calling multiple borg subcommands with many flags, we just have a single configuration file `config.yaml`.
It also prunes archives automatically after a backup, and integrates with healthchecks.

We will be calling borgmatic in our final backup script.

Adjust `ssh_command` in borgmatic's `config.yaml` to our newly generated key. You can also add an alias in your ssh `config` for simpler server access.

While we are in `config.yaml`, set up monitoring. Create a check on healthchecks.io and paste its ping URL into the
`healthchecks` section. Borgmatic pings it when a run starts, succeeds or fails, so a backup that dies halfway, or never
starts at all, shows up as a missing ping. Then go to the healthchecks project settings and add a notification, email at
the very least.

### Borg repo configuration

Once the secure connection to the server is configured, we can move to setting up the borg repo.

Make sure the borg version locally is compatible with the one installed on the server. Adjust borgmatic `config.yaml` to that version.

```bash
borg init --encryption=repokey-blake2 --remote-path=borg-1.4 ssh://u672410@u672410.your-storagebox.de:23/./backups/mac
```

Encryption is either `repokey` or `keyfile`. `repokey` stores the key in the repo and encrypts it with a passphrase.
`keyfile` is a separate file with the key, which needs a separate backup of its own, so for simplicity I go with `repokey`.

The repo passphrase should be stored in a password manager AND offline to prevent locking yourself out (the passphrase lives in the password
manager - but if you lose the password manager database, its only copy is inside the backup you now can't open).

Store the encryption passphrase in System Keychain, so the background cron job can fetch it at runtime.

```bash
sudo security add-generic-password -U -a borg -s borg-hetzner /Library/Keychains/System.keychain -w
```

Back up the repo key itself. Into the password manager and offline. The passphrase plus this repo key is the whole restore path.

```bash
borg key export --paper --remote-path=borg-1.4 ssh://u672410@u672410.your-storagebox.de:23/./backups/mac
```

Encryption works like this: backups are encrypted with a random borg key `repokey`, which is generated during init.
`repokey` sits in the config file next to the backup data, and is encrypted with the passphrase. So passphrase -> config file -> `repokey` -> data.
If we lose the config file in that chain, we are unable to decrypt the data - that's why we back up the `repokey` offline.

You can specify the `--remote-path` borg CLI argument to say which version of borg to use on the remote, if several versions are available.

Ok, that should be it for the borg repo configuration.

### Local configuration

We have a `borg-run.sh` script that runs the backups using borgmatic with our `config.yaml`, and handles
stuff like mounting the filesystem, keeping the machine awake etc.

The mounting part is worth explaining, because it looks odd in the config. The script does not back up the live
filesystem. It first takes an APFS (Apple File System) snapshot with `tmutil localsnapshot`, mounts it read-only under
`/private/tmp/borg-snap`, and runs borgmatic against that mount, deleting the snapshot on exit. This way borg reads one
consistent point in time instead of files changing under it during a run that takes half an hour.

Run the `install.sh` script as root. It will set up the cron job and log rotation, and install the binaries
in the correct directories.

The daemon cannot wake a sleeping Mac, so give it a wake schedule for when the backups run.

```bash
sudo pmset repeat wakeorpoweron MTWRFSU 03:30:00
```

### macOS Full Disk Access (FDA)

This only applies to macOS. Programs that interact with the filesystem need to have Full Disk Access (FDA) enabled.
Unfortunately, we can't enable it for individual bash scripts, only for the whole shell `/bin/bash`, which is a bad
idea from a security perspective. So we write a simple C wrapper, `borg-wrapper.c`, whose only job is to execute
`borg-run.sh`. The binary also has to be `codesign`ed in order to give it FDA.

The `install.sh` script should handle this already. To enable FDA, go to Privacy & Security -> Full Disk Access
and enable it for the `borg-wrapper` binary. The permission resets every time the binary is recompiled, so keep that in mind.

### Test run

The setup is done! Now we can test it by manually invoking the daemon.

```bash
sudo launchctl kickstart system/com.hxwk.borgbackup && sudo tail -f /var/log/borgbackup.log
```

Check if the healthcheck went green.

### Final touches

Once the backups are working, there are two more things to configure: enabling Storage Box
snapshots and locking down the SSH key on the box.

Go to the Storage Box dashboard and enable daily automatic snapshots, keeping the last 7 and
leaving 3 slots for manual ones, to use before you do anything irreversible. Set the execution time
to 6:00 UTC, so the backup run can finish before the snapshot is taken.

Adjust the `authorized_keys` file and upload it to the server. It will restrict our SSH key to
only run the `borg serve` command, and it will prevent any other SSH access.

```bash
echo "put backups/authorized_keys .ssh/authorized_keys" | sftp -P 23 u672410@u672410.your-storagebox.de
```

### Restore testing

After the first backup has run, check that restore works:

```bash
sudo borgmatic --config ~/.config/borgmatic/config.yaml extract --archive latest --path /Users/hxwk/Passwords.kdbx --destination /tmp/restore
```

The file should be accessible.

### Integrating with other devices

#### Mobile

There are some things worth backing up from a phone. One of them is 2FA codes.
I use Android Aegis, which automatically writes up to 10 passphrase-encrypted backups to the filesystem whenever the vault changes.
Then I sync that folder to my home directory with Syncthing, where the borg backup picks it up!

Syncthing is also a nice solution for syncing the password manager database between two devices.

#### Other devices

If I wanted to add another device to the borg backup, I would just configure a second borg repo and follow the same steps.
I would keep a separate `config.yaml` for that repo.

## Offline backup

The cloud backup covers the laptop dying or being stolen. It does not cover losing access to the Hetzner
account. So the second copy goes on an external drive in a drawer. Together with the cloud repo that gives the
classic 3-2-1: the live data, a local copy and an offsite copy.

The good news is that all the hard parts are already done. The drive is just another borg repository in the same
`config.yaml`, with the same sources, the same excludes and the same retention, so it also gets the APFS snapshot
treatment for free.

If you wanted different retention, excludes, etc. for offline backup, then separate `config.yaml` will be needed.

### Preparing the drive

Format it as APFS.

The drive does not need to be encrypted, because borg encrypts everything it writes anyway. An encrypted APFS
volume would only add an unlock step that a background job can't do on its own.

Disable Spotlight indexing of a borg repository.

```bash
sudo mdutil -i off /Volumes/External-Physical
```

### Creating the repo

```bash
sudo borg init --encryption=repokey-blake2 /Volumes/External-Physical/borg-mac
```

Use the same passphrase as the cloud repo - one `config.yaml` has one `encryption_passcommand`, so both
repositories have to open with the same passphrase. Each repo still gets its own random key.

If you have higher threat model you can configure separate `config.yaml` with different encryption passphrase.

The drive only gets a backup when it happens to be attached at 03:30, so it is worth plugging it in every now and
then and leaving it overnight.

### Test it

```bash
sudo launchctl kickstart system/com.hxwk.borgbackup
sudo borgmatic --config ~/.config/borgmatic/config.yaml repo-list --repository external
```

Then unplug the drive and run the daemon again. The log should say _skipping remaining repository actions_, the
cloud backup should finish normally and the healthcheck should still go green.

## Full restore

This is the section that matters. Everything above is plumbing whose only purpose is to make this one possible.

### What you need that is not in the backup

Three things. Lose all of them and the backup is a pile of random bytes.

- The repo passphrase. In the password manager and offline on paper.
- The paper key export. Only needed if the repo's own `config` file is damaged.
- A way into the box (for cloud backup). The SSH private key lives in `~/.ssh`, which is inside the backup, so it is of no help here.
  The realistic path is the Hetzner account: reset the Storage Box password in the console and let `ssh` ask for it.
  So the Hetzner credentials and 2FA recovery codes belong offline as well.

The repo URL is not a secret and it sits in `config.yaml` in this repo, so that part you can always look up.

### Getting to a shell that has borg in it

On a fresh Mac, in this order:

1. Create the user account with the same short name, `hxwk`. Archive paths are `Users/hxwk/...`, and a different
   username means relocating every path by hand later.
2. Clone this repo and run `./bootstrap.sh`. It installs the Command Line Tools, Homebrew and everything in
   `setup/programs`, borg and borgmatic included, and links the dotfiles so `config.yaml` lands in
   `~/.config/borgmatic/`.

That is enough to read the backup. Don't run `backups/install.sh` yet - there is no sense scheduling backups of a
machine that has nothing on it.

### Looking inside

Point borg at the repo and let it prompt for the passphrase. There is no reason to put it in the environment for an
interactive restore.

```bash
export BORG_REPO=/Volumes/External-Physical/borg-mac   # or ssh://u672410@u672410.your-storagebox.de:23/./backups/mac
borg list
```

For the cloud repo, add `--remote-path=borg-1.4` to every command, or borg will call the wrong version on the server.

Mounting is the pleasant way to look around, because from there it is just a filesystem and `ls`, Finder and `rsync`
all work on it:

```bash
mkdir -p /tmp/restore
borg mount ::ARCHIVE /tmp/restore
borg umount /tmp/restore
```

### Extracting

Archive paths carry no leading slash, because we back up `Users/hxwk` relative to the snapshot mount. They look like
`Users/hxwk/Documents/...`, and `borg extract` writes them relative to the current directory. So `cd` somewhere empty
first, or you will scatter a home directory across whatever you happened to be standing in.

```bash
cd /tmp/restore
sudo borg extract ::ARCHIVE Users/hxwk/Documents
```

Run it under `sudo` to get the original ownership and permissions back, then move the result into place. Don't extract
straight over a live `~` while logged in as that user, and be especially careful with `Users/hxwk/Library` - restoring
it under a running session is how you break a freshly installed Mac. Stage it, then move it.

For a single file, borgmatic is shorter:

```bash
sudo borgmatic --config ~/.config/borgmatic/config.yaml extract --archive latest \
  --path Users/hxwk/Sync/keepassxc/Passwords.kdbx --destination /tmp/restore
```

### Finishing the machine

Once the home directory is back:

1. `sudo backups/install.sh`, then the manual steps it prints: the passphrase into the System Keychain, Full Disk
   Access for the wrapper, the wake schedule.
2. Run a backup by hand and check that the healthcheck goes green before trusting the new machine.

### If the repo itself is the problem

Ransomware, or a `borg delete` you regret. The Storage Box snapshots are the answer here, but the SSH key cannot
reach them: `--restrict-to-repository` in `authorized_keys` rejects every path outside the repo, including
`/home/.zfs/snapshot`. Browse or roll back a snapshot from the Hetzner console or API - one more reason the account
credentials belong offline.
