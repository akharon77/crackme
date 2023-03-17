#include <stdint.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

const char *outputFilename = "passden.txt";
const uint8_t patch[3] = {0x95, 0x01, 0x0D};

uint8_t buf[0xFFFB - 0x250 + 1 + 3] = {0};

int main()
{
    int32_t fd = creat(outputFilename, S_IRWXU);

    memcpy(buf + 0xFFFB - 0x250 + 1, patch, 3);

    write(fd, buf, sizeof(buf));
    close(fd);
    return 0;
}
