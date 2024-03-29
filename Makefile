OCAMLC=ocamlc
OCAMLDEP=ocamldep
OCAMLFLAGS=

MODULE_NAME=main
SOURCE_FILE=main.ml

.PHONY: all clean

all: $(MODULE_NAME) utop

$(MODULE_NAME): $(SOURCE_FILE)
	$(OCAMLC) $(OCAMLFLAGS) -o $@ $<

utop: $(MODULE_NAME)
	utop -I . -init $(MODULE_NAME).cmo

clean:
	rm -f $(MODULE_NAME) $(MODULE_NAME).cmi $(MODULE_NAME).cmo
