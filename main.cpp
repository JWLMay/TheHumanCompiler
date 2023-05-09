#include <iostream>

class myQ
{
public:
    myQ (int* arr, int size): arrc(arr), sizec(size) {}
    void runQs() {
        if (sizec > 8) {
            stepOne(); // Set pivot(get median, swap with size - 2)
            stepTwo(); // Sort with pivot
            //Divide and Conquer
            myQ left(arrc, pivot);
            left.runQs();
            myQ right(arrc + (pivot + 1), sizec - pivot - 1);
            right.runQs();
        }
        else inSort();
        return;
    }

    void printArr() {
        std::cout << '\n';
        for(int i = 0; i < sizec; ++i) std::cout << arrc[i] << ' ';
        std::cout << '\n';
        return;
    }
    
private:
    int* arrc;
    int sizec;
    int pivot;
    
    void stepOne() {
        if (arrc[0] > arrc[sizec/2]) elSwap(0, sizec/2);
        if (arrc[sizec/2] > arrc[sizec - 1]) elSwap(sizec/2, sizec - 1);
        if (arrc[0] > arrc[sizec/2]) elSwap(0, sizec/2);
        elSwap(sizec - 2, sizec/2);
        pivot = arrc[sizec - 2];
        return;
    }
    
    void stepTwo() {
        int i = 1, j = sizec - 3;
        while (i < j) {
            while (arrc[i] < pivot) ++i;
            while (arrc[j] > pivot) --j;
            if (i < j) elSwap(i, j);
        }
        elSwap(sizec - 2, i);
        pivot = i;
        return;
    }

    void elSwap(int idx1, int idx2) {
        int tmp = arrc[idx1];
        arrc[idx1] = arrc[idx2];
        arrc[idx2] = tmp;
        return;
    }

    void inSort() {
        for(int k = 1; k < sizec; k++) {
            int element = arrc[k];
            int l = k;
            for(; l && (arrc[l-1] > element); l--) {
                arrc[l] = arrc[l-1];
            }
            arrc[l] = element;
        }
    }
};

int main() {
    int test[] = {5, 2, 7, 11, 3, 10, 19, 17, 14, 13, 1, 15, 8, 4, 6, 12, 18, 20, 9, 16};
    myQ testQ(test, 20);
    testQ.runQs();
    testQ.printArr();
    return 0;
}