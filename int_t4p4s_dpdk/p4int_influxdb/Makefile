##
# @author Mario Kuka <kuka@cesnet.cz>
#         Pavlina Patova <xpatov00@stud.fit.vutbr.cz>
# @brief Header file of INT sink node
##

BIN=p4int
CXX=g++
CXXFLAGS=-std=c++17 -Wextra -pedantic -Wno-format-overflow
INT_FILES=p4int.cc p4int.h p4_influxdb.cc p4_influxdb.h UDP.cc UDP.h HTTP.cc HTTP.h ringbuffer.h

DEBUG ?= 0
ifeq ($(DEBUG), 1)
CXXFLAGS +=-O0 -g 
else
CXXFLAGS +=-O2 -O3
endif

LIBS=-lm -lpthread -lboost_system -lcurl

p4int: $(INT_FILES)
	@echo "Using CXXFLAGS = $(CXXFLAGS)"
	$(CXX) -o $(BIN) $(CXXFLAGS) $(INT_FILES) $(LIBS)

clean:
	rm -f *.a *.o $(BIN)

mrproper: clean
	rm $(BIN) 
