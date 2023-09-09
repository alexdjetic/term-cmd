#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/fs.h>

enum OS {
    WINDOWS,
    LINUX,
    OTHER
};

int failed();
int success();
int requirement();
void encrypt(char *device);

int main(int argc, char** argv) {
  char device[20];

  if (argc == 1) {
    // Use lsblk to choose the disk
    puts("Available disks:");
    system("lsblk");
    puts("Enter the name of the disk to encrypt (e.g. /dev/sda1):");
    scanf("%s", device);
  } else {
    // Use the disk name passed as an argument
    strcpy(device, argv[1]);
  }

  encrypt(device);
  return success();
}

int failed() {
    printf("Encryption failed.\n");
    return 1;
}

int success() {
    printf("Encryption succeeded.\n");
    return 0;
}

int requirement() {
    enum OS os = OTHER;

#ifdef _WIN32
    os = WINDOWS;
#elif __linux__
    os = LINUX;
#endif

    if (os == LINUX) {
        return 0;
    } else if (os == WINDOWS) {
        printf("Encrypting disk on Windows is not supported yet.\n");
    } else {
        printf("Encrypting disk on this operating system is not supported yet.\n");
    }

    return 1;
}

void encrypt(char *device) {
    char cmd[1024];
    sprintf(cmd, "cryptsetup luksFormat %s", device);

    int status = system(cmd);

    if (status != 0) {
        printf("Error encrypting device %s\n", device);
        exit(failed());
    }

    char mapped[1024];
    sprintf(mapped, "%s_mapped", device);

    sprintf(cmd, "cryptsetup open %s %s", device, mapped);

    status = system(cmd);

    if (status != 0) {
        printf("Error opening encrypted device %s\n", device);
        exit(failed());
    }

    printf("Device %s successfully encrypted.\n", device);
}
