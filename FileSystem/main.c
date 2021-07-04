
#include <stdio.h>
#include <time.h>
#include <stdbool.h>

#include "file_system.h"

#define EXIT_SUCCESS 0
#define EXIT_ERROR 1

/**
 * This is the entry-point to the application.
 *
 * @param argument_count The number of arguments that were passed to the application via the command line.
 * @param arguments A pointer to an array of the arguments. The array contains argument_count many items.
 * @return Returns an exit code, which determines whether the application exited successfully or an error occurred.
 */
int main(int argument_count, char* arguments[]) {

    // Checks if the number of arguments matches the expected number of arguments (the first argument is the name of the application, the second is the file system image file name)
    if (argument_count != 2) {
        fprintf(stderr, "No file name for the file system image was specified.\n");
        return EXIT_ERROR;
    }

    // Opens the file system image
    FileSystemImage* file_system_image = open_file_system_image(arguments[1]);
    if (file_system_image == NULL) {
        fprintf(stderr, "The file system image could not be opened.\n");
        return EXIT_ERROR;
    }

    // Checks if the file system image contains a valid file system, if not, then it is formatted
    if (!is_file_system_image_valid(file_system_image)) {
        fprintf(stderr, "The image does not contain a valid AxiomFS file system. Formatting the image...\n");
        format_file_system_image(file_system_image, NULL);
        fprintf(stderr, "Successfully formatted the image.\n");
    }

    // Opens the file system from the image
    FileSystem* file_system = open_file_system(file_system_image);
    if (file_system == NULL) {
        fprintf(stderr, "The file system could not be opened.\n");
        return EXIT_ERROR;
    }

    // Prints out information about the file system
    printf("Volume name: %s\n", file_system->header->volume_name);
    char creation_date_time[20];
    time_t creation_time = (time_t)file_system->header->creation_time;
    strftime(creation_date_time, 20, "%Y-%m-%d %H:%M:%S", localtime(&creation_time));
    printf("Creation datetime: %s\n", creation_date_time);
    printf("File system version: %d.%d\n", file_system->header->major_version, file_system->header->minor_version);
    printf("Number of 4 KiB blocks: %d\n", file_system->header->number_of_blocks);
    printf("Number of blocks used: %d\n", file_system->header->number_of_used_blocks);
    printf("Number of blocks free: %d\n", file_system->header->number_of_free_blocks);

    // Closes the file system
    if (!close_file_system(file_system)) {
        fprintf(stderr, "The file system could not be closed.\n");
        return EXIT_ERROR;
    }

    // Closes the file system image
    if (!close_file_system_image(file_system_image)) {
        fprintf(stderr, "The file system image could not be closed.\n");
        return EXIT_ERROR;
    }

    // Exits the application with a success code, since nothing went wrong
	return EXIT_SUCCESS;
}
