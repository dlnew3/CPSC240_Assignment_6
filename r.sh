#Author: Dennis Newman
#Program Name: Harmonic Sum

rm *.o
rm *.out
rm *.lis

echo "Assemble manager.asm"
nasm -f elf64 -l manager.lis -o manager.o manager.asm

echo "Assemble getfreq.asm"
nasm -f elf64 -l getfreq.lis -o getfreq.o getfrequency.asm

echo "Compile main.cpp"
g++ -c -m64 -Wall -o main.o main.cpp -fno-pie -no-pie -std=c++17

echo "Link the object files"
g++ -m64 -o a.out main.o manager.o getfreq.o -fno-pie -no-pie -std=c++17

echo "----- Run the program -----"
./a.out
echo "----- Program finished -----"