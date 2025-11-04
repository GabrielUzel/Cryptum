"use client";

import "./pdf-worker";
import { useState, useEffect } from "react";
import { Document, Page } from "react-pdf";
import { Button } from "@/components/ui/button";
import { useCompile } from "@/hooks/use-compile";
import { downloadFileForCompilation } from "@/hooks/use-files";
import Image from "next/image";
import "react-pdf/dist/Page/AnnotationLayer.css";
import "react-pdf/dist/Page/TextLayer.css";

type CompilerProps = {
  projectId: string;
  currentFileId: string | null;
};

export default function Compiler(props: CompilerProps) {
  const { projectId, currentFileId } = props;
  const [pdfUrl, setPdfUrl] = useState<string>();
  const [numPages, setNumPages] = useState<number>();
  const [pageNumber, setPageNumber] = useState<number>(1);
  const [pdfBlob, setPdfBlob] = useState<Blob | null>(null);
  const [compiledFilename] = useState<string>("");

  const { mutateAsync, isPending } = useCompile();

  const handleCompile = async () => {
    try {
      if (!currentFileId) {
        throw new Error("No file selected");
      }

      const file = await downloadFileForCompilation(projectId, currentFileId);
      const result = await mutateAsync(file);

      if (result.pdf) {
        const binaryString = atob(result.pdf);
        const bytes = new Uint8Array(binaryString.length);

        for (let i = 0; i < binaryString.length; i++) {
          bytes[i] = binaryString.charCodeAt(i);
        }

        const blob = new Blob([bytes], { type: "application/pdf" });
        const url = URL.createObjectURL(blob);

        setPdfBlob(blob);
        setPdfUrl(url);
      }
    } catch (error) {
      console.error("Erro na compilação:", error);
      setPdfUrl(undefined);
      setPdfBlob(null);
    }
  };

  function onDocumentLoadSuccess({ numPages }: { numPages: number }): void {
    setNumPages(numPages);
  }

  const handleDownloadPdf = () => {
    if (pdfBlob) {
      const url = URL.createObjectURL(pdfBlob);
      const a = document.createElement("a");
      a.href = url;
      a.download = compiledFilename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    }
  };

  useEffect(() => {
    return () => {
      if (pdfUrl) {
        URL.revokeObjectURL(pdfUrl);
      }
    };
  }, [pdfUrl]);

  return (
    <section className="flex-1 bg-card p-4 rounded-lg flex flex-col">
      <div className="flex-1 flex items-center justify-center min-h-[400px]">
        {isPending ? (
          <div className="text-center">
            <p>Compilando arquivo...</p>
          </div>
        ) : pdfUrl ? (
          <div className="w-full h-full flex flex-col">
            <div className="flex-1 flex justify-center">
              <Document file={pdfUrl} onLoadSuccess={onDocumentLoadSuccess}>
                <Page pageNumber={pageNumber} />
              </Document>
            </div>
          </div>
        ) : (
          <div className="text-center">
            <p className="text-muted-foreground">
              {currentFileId
                ? `Clique em "Compilar" para gerar o PDF`
                : "Selecione um arquivo .tex para compilar"}
            </p>
          </div>
        )}
      </div>

      <div className="flex justify-between">
        <div className="flex gap-2">
          <Button
            onClick={handleCompile}
            disabled={!currentFileId || isPending}
            className="cursor-pointer"
          >
            {isPending ? "Compilando..." : "Compilar"}
          </Button>
          {pdfUrl && (
            <Button
              onClick={handleDownloadPdf}
              className="cursor-pointer"
              variant="secondary"
            >
              Baixar PDF
            </Button>
          )}
        </div>
        {pdfUrl && (
          <div className="flex gap-4 items-center">
            <p className="">
              Página {pageNumber} de {numPages}
            </p>
            <div className="flex gap-2">
              <Button
                className="cursor-pointer hover:bg-primary hover:text-white p-1 border-none"
                variant="outline"
                size="sm"
                onClick={() => setPageNumber(Math.max(1, pageNumber - 1))}
                disabled={pageNumber <= 1}
              >
                <Image
                  src="/previous-page.svg"
                  alt="Página anterior"
                  width={30}
                  height={30}
                />
              </Button>
              <Button
                className="cursor-pointer hover:bg-primary hover:text-white p-1 border-none"
                variant="outline"
                size="sm"
                onClick={() =>
                  setPageNumber(Math.min(numPages || 1, pageNumber + 1))
                }
                disabled={pageNumber >= (numPages || 1)}
              >
                <Image
                  src="/next-page.svg"
                  alt="Próxima página"
                  width={30}
                  height={30}
                />
              </Button>
            </div>
          </div>
        )}
      </div>
    </section>
  );
}
