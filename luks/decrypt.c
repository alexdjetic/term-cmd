#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LUKS_HEADER_SIZE 4096

int main(int argc, char *argv[])
{
    char encrypted_device[100];
    char decrypted_device[100];
    char passphrase[100];

    // Check that the user provided the required arguments
    if (argc < 3) {
        printf("Usage: %s encrypted_device decrypted_device\n", argv[0]);
        return 1;
    }

    // Read the encrypted device and decrypted device names from the command line
    strcpy(encrypted_device, argv[1]);
    strcpy(decrypted_device, argv[2]);

    // Read the passphrase from the user
    printf("Enter passphrase: ");
    scanf("%s", passphrase);

    // Use cryptsetup to decrypt the device
    char command[1000];
    sprintf(command, "cryptsetup luksOpen %s %s --key-file=-", encrypted_device, decrypted_device);
    FILE *fp = popen(command, "w");
    fwrite(passphrase, 1, strlen(passphrase), fp);
    fwrite("\n", 1, 1, fp);
    pclose(fp);

    return 0;
}
