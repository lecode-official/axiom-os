
#include <stdbool.h>

#ifndef FILE_SYSTEM_H
#define FILE_SYSTEM_H

/**
 * Represents the header of the file system, which contains global file system information.
 */
typedef struct FileSystemHeader {

    /**
     * Contains the magic number by which the file system is identified, for AxionFS, this is "DN" or 0x44, 0x4E.
     */
    char magic_number[2];

    /**
     * Contains the major version of the file system.
     */
    unsigned short int major_version;

    /**
     * Contains the minor version of the file system.
     */
    unsigned short int minor_version;

    /**
     * Contains the UNIX timestamp of the creation time.
     */
    unsigned int creation_time;

    /**
     * Contains the total number of blocks available in the file system. One block is 4096 bytes.
     */
    unsigned int number_of_blocks;

    /**
     * Contains the number of blocks in the file system that are already occupied. number_of_used_blocks + number_of_free_blocks = number_of_blocks
     * must always hold true, after all operations on the file system.
     */
    unsigned int number_of_used_blocks;

    /**
     * Contains the number of free blocks in the file system. From the difference the amount of free space can be calculated.
     */
    unsigned int number_of_free_blocks;

    /**
     * Contains the name of the volume, which is a user-defined string.
     */
    char volume_name[1024];
} FileSystemHeader;

/**
 * Represents structure, which contains the file system image, which is just the memory mapped image file that contains the file system.
 */
typedef struct FileSystemImage {

    /**
     * Contains the file name of the file system image file.
     */
    char* file_name;

    /**
     * Contains the size of the file system image in bytes.
     */
    int size;

    /**
     * Contains a pointer to the memory region that contains the whole memory mapped file system image.
     */
    char* memory;
} FileSystemImage;

/**
 * Represents a structure, which contains the information about the file system.
 */
typedef struct FileSystem {

    /**
     * Contains a pointer to the image of the file system.
     */
    FileSystemImage* image;

    /**
     * Contains a pointer to the header of the file system, which contains all global information about the file system.
     */
    FileSystemHeader* header;
} FileSystem;

/**
 * Opens the specified image file and maps it into virtual memory, so that everything can be read from it.
 *
 * @param file_name The name of the file system image file.
 * @return Returns a pointer to the file system image structure, which contains the memory mapped file system image.
 */
FileSystemImage* open_file_system_image(char* file_name);

/**
 * Closes the file system image, writes all unwritten data to disk, and releases the memory that was allocated for the file system image structure.
 *
 * @param file_system_image The file system image structure that contains the memor mapped file system image.
 * @returns Returns truze if the file system image was successfully closed and false otherwise.
 */
bool close_file_system_image(FileSystemImage* file_system_image);

/**
 * Determines if the file system image contains a valid AxiomFS file system.
 *
 * @param file_system_image A pointer to the file system image structure that contains the memory mapped file system image.
 * @returns Returns true if the file system image contains a valid AxiomFS file system.
 */
bool is_file_system_image_valid(FileSystemImage* file_system_image);

/**
 * Formats the specified file system image.
 *
 * @param file_system_image A pointer to the file system image structure that is to be formatted.
 * @param volume_name The name of the file system volume. If NULL, a standard name will be used.
 */
void format_file_system_image(FileSystemImage* file_system_image, char* volume_name);

/**
 * Parses the file system image for all the information needed to work with the file system.
 *
 * @param file_system_image A pointer to the file system image that contains the whole data of the file system, which is to be parsed.
 * @returns Returns a pointer to a file system structure, which contains the parsed information of the file system.
 */
FileSystem* open_file_system(FileSystemImage* file_system_image);

/**
 * Frees all memory allocated by the file system structure.
 * @param file_system A pointer to the file system structure that is to be closed.
 * @returns Returns true if the file system was successfully closed, and false otherwise.
 */
bool close_file_system(FileSystem* file_system);

#endif