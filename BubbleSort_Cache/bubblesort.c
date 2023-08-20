#include <stdio.h>
#include <stdlib.h>

// Funktion für Bubble Sort mit Cache-Optimierungen
void bubbleSort(int array[], int length) {
    int i, j, tmp;
    int swapped;
    
    for (i = 1; i < length; i++) {
        swapped = 0; // Flag, um zu überprüfen, ob in dieser Iteration Vertauschungen stattgefunden haben
        for (j = 0; j < length - i; j++) {
            if (array[j] > array[j + 1]) {
                tmp = array[j];
                array[j] = array[j + 1];
                array[j + 1] = tmp;
                swapped = 1; // Es wurde eine Vertauschung durchgeführt
            }
        }
        if (swapped == 0) {
            // Keine Vertauschungen in dieser Iteration, das Array ist bereits sortiert
            break;
        }
    }
}



