#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE_LENGTH 1024

int count_words(const char *line) {
    int count = 0;
    int in_word = 0;
    for (const char *p = line; *p; p++) {
        if (*p == ' ' || *p == '\t' || *p == '\n') {
            in_word = 0;
        } else if (!in_word) {
            in_word = 1;
            count++;
        }
    }
    return count;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return EXIT_FAILURE;
    }
    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        perror("fopen");
        return EXIT_FAILURE;
    }
    char line[MAX_LINE_LENGTH];
    int total_words = 0;
    while (fgets(line, sizeof(line), fp)) {
        total_words += count_words(line);
    }
    fclose(fp);
    printf("Total words: %d\n", total_words);
    return EXIT_SUCCESS;
}
