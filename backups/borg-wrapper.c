/*
 * Wrapper for borg-run.sh script. Needed only on MacOS, because the FDA can't be given to the bash scripts
 * directly, only to binaries.
 */
#include <unistd.h>
int main(void) {
    execl("/bin/bash", "bash", "/usr/local/bin/borg-backup.sh", (char *)0);
    return 1;
}
