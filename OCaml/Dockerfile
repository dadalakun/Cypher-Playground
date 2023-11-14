FROM ocaml/opam:alpine

WORKDIR /app

# Copy the source file into the container
COPY visualize.ml .

# Install yosjon
RUN opam install yojson ocamlfind

# Initialize the environment variables and compile in the same shell
RUN eval $(opam env) && \
    ocamlopt -o visualize -I /home/opam/.opam/5.1/lib/yojson yojson.cmxa visualize.ml

CMD ["/bin/sh"]