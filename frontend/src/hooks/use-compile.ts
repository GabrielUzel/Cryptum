import { useMutation } from "@tanstack/react-query";
import { CompilerGateway } from "@/api/compiler/compiler.gateway";

const compilerGateway = new CompilerGateway();

export const useCompile = () => {
  return useMutation({
    mutationFn: async (file: File) => {
      return await compilerGateway.compile(file);
    },
  });
};
