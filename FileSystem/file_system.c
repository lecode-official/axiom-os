
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>

#include "file_system.h"

/**
 * Opens the specified image file and maps it into virtual memory, so that everything can be read from it.
 *
 * @param file_name The name of the file system image file.
 * @return Returns a pointer to the file system image structure, which contains the memory mapped file system image.
 */
FileSystemImage* open_file_system_image(char* file_name) {

    // Allocates enough memory for the file system image structure
    FileSystemImage* file_system_image = malloc(sizeof(FileSystemImage));
    if (file_system_image == NULL) {
        return NULL;
    }

    // Stores a copy of the file name in the file system image structure
    file_system_image->file_name = malloc(sizeof(char) * strlen(file_name));
    if (file_system_image->file_name == NULL) {
        return NULL;
    }
    strcpy(file_system_image->file_name, file_name);

    // Opens the image file so it can be memory mapped
    int file_descriptor = open(file_name, O_RDWR);
    if (file_descriptor == -1) {
        return NULL;
    }

    // Gets the file status and checks if the file is a regular file
    struct stat file_status;
    if (fstat(file_descriptor, &file_status) == -1) {
        return NULL;
    }
    if (!S_ISREG(file_status.st_mode)) {
        return NULL;
    }

    // Stores the size of the file system image
    file_system_image->size = file_status.st_size;

    // Creates the memory map for the contents of the file system image, which can be read or written to
    file_system_image->memory = mmap(0, file_status.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, file_descriptor, 0);
    if (file_system_image->memory == MAP_FAILED) {
        return NULL;
    }

    // Closes the file system image file (memory mapping a file increases the reference count to the file, which means, the file does not need to kept open)
    if (close(file_descriptor) == -1) {
        return NULL;
    }

    // Returns the created file system image
    return file_system_image;
}

/**
 * Closes the file system image, writes all unwritten data to disk, and releases the memory that was allocated for the file system image structure.
 *
 * @param file_system_image The file system image structure that contains the memor mapped file system image.
 * @returns Returns truze if the file system image was successfully closed and false otherwise.
 */
bool close_file_system_image(FileSystemImage* file_system_image) {

    // Checks if the pointer is still valid
    if (file_system_image == NULL) {
        return false;
    }

    // Flushes back to disk all the changes made to the memory mapping of the file system image
    bool successful = true;
    if (msync(file_system_image->memory, file_system_image->size, MS_SYNC)) {
        successful = false;
    }

    // Unmaps the memory mapped region of the file system image
    if (munmap(file_system_image->memory, file_system_image->size) == -1) {
        successful = false;
    }

    // Frees the memory that was allocated for the properties of the file system image
    free(file_system_image->file_name);

    // Frees the file system image structure itself
    free(file_system_image);

    // Returns true if the closing was successful and false otherwise
    return successful;
}

/**
 * Determines if the file system image contains a valid AxiomFS file system.
 *
 * @param file_system_image A pointer to the file system image structure that contains the memory mapped file system image.
 * @returns Returns true if the file system image contains a valid AxiomFS file system.
 */
bool is_file_system_image_valid(FileSystemImage* file_system_image) {

    // Retrieves a pointer to the header of the file system
    FileSystemHeader* file_system_header = (FileSystemHeader*)(file_system_image->memory + 4096);

    // Checks if the magic number of the file system is correct
    if (file_system_header->magic_number[0] != 'D' || file_system_header->magic_number[1] != 'N') {
        return false;
    }

    // Determines if the major and minor version of the file system is valid (the only valid version number right now is 0.1)
    if (file_system_header->major_version != 0 || file_system_header->minor_version != 1) {
        return false;
    }

    // Checks if the number of free and used blocks add up to the total size of the file system
    if (file_system_header->number_of_used_blocks + file_system_header->number_of_free_blocks != file_system_header->number_of_blocks) {
        return false;
    }

    // Since the file system passed all checks, true is returned
    return true;
}

/**
 * Formats the specified file system image.
 *
 * @param file_system_image A pointer to the file system image structure that is to be formatted.
 * @param volume_name The name of the file system volume. If NULL, a standard name will be used.
 */
void format_file_system_image(FileSystemImage* file_system_image, char* volume_name) {

    // Retrieves a pointer to the header of the file system
    FileSystemHeader* file_system_header = (FileSystemHeader*)(file_system_image->memory + 4096);

    // Adds the magic number to the header, which identifies the file system as AxiomFS
    file_system_header->magic_number[0] = 'D';
    file_system_header->magic_number[1] = 'N';

    // Adds the file system version (0.1 is the current and only version of AxiomFS)
    file_system_header->major_version = 0;
    file_system_header->minor_version = 1;

    // Adds the number of blocks in the file system (the fist block contains the boot sector and the second block contains the file system
    // header, therefore already two blocks are occupied)
    unsigned int number_of_blocks = (int)floor((float)file_system_image->size / (float)4096);
    file_system_header->number_of_blocks = number_of_blocks;
    file_system_header->number_of_used_blocks = 2;
    file_system_header->number_of_free_blocks = file_system_header->number_of_blocks - file_system_header->number_of_used_blocks;

    // Adds the creation date time of the file system
    file_system_header->creation_time = (unsigned int)time(NULL);

    // Adds the volume name to the file system
    if (volume_name == NULL) {
        strcpy(file_system_header->volume_name, "AxiomFS Volume");
    } else {
        strcpy(file_system_header->volume_name, volume_name);
    }
}

/**
 * Parses the file system image for all the information needed to work with the file system.
 *
 * @param file_system_image A pointer to the file system image that contains the whole data of the file system, which is to be parsed.
 * @returns Returns a pointer to a file system structure, which contains the parsed information of the file system.
 */
FileSystem* open_file_system(FileSystemImage* file_system_image) {

    // Allocates enough memory for the file system structure
    FileSystem* file_system = malloc(sizeof(FileSystem));
    if (file_system == NULL) {
        return NULL;
    }

    // Stores a reference to the file system image
    file_system->image = file_system_image;

    // Gets a reference to the file system header, which is statically position in the second block of the file system image (one block is 4 KiB)
    file_system->header = (FileSystemHeader*)(file_system_image->memory + 4096);

    // Returns the parsed file system
    return file_system;
}

/**
 * Frees all memory allocated by the file system structure.
 * @param file_system A pointer to the file system structure that is to be closed.
 * @returns Returns true if the file system was successfully closed, and false otherwise.
 */
bool close_file_system(FileSystem* file_system) {

    // Checks if the pointer is still valid
    if (file_system == NULL) {
        return false;
    }

    // Frees the file system structure itself
    free(file_system);

    // Returns true since the file system was closed successfully
    return true;
}
