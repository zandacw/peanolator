OCAMLC = ocamlc
OCAMLFLAGS = -w +A-4-9-27
SOURCES = peano.ml parser.ml main.ml 
OBJECTS = $(SOURCES:.ml=.cmo)
EXECUTABLE = main

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(OCAMLC) $(OCAMLFLAGS) -o $@ $(OBJECTS)

%.cmo: %.ml
	$(OCAMLC) $(OCAMLFLAGS) -c $<

clean:
	rm -f $(EXECUTABLE) $(OBJECTS) $(SOURCES:.ml=.cmi)
