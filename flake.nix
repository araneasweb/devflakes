{
  outputs = _: {
    templates = {
      typescript = {
        path = ./typescript;
      };
      default = {
        path = ./default;
      };
      apl = {
        path = ./apl;
      };
      ocaml = {
        path = ./ocaml;
      };
      racket = {
        path = ./racket;
      };
      agda = {
        path = ./agda;
      };
    };
  };
}
