"use client";

import "./pdf-worker";
import { useState, useEffect } from "react";
import { Document, Page } from "react-pdf";
import { Button } from "@/components/ui/button";
import { useCompile } from "@/hooks/use-compile";
import { downloadFileForCompilation } from "@/hooks/use-files";
import Image from "next/image";
import { AxiosError } from "axios";

type CompilerProps = {
  projectId: string;
  currentFileId: string | null;
};

type CompileResult = {
  pdf?: string;
  log?: string;
  error?: string[];
  message?: string;
  filename?: string;
};

export default function Compiler(props: CompilerProps) {
  const { projectId, currentFileId } = props;
  const [pdfUrl, setPdfUrl] = useState<string>();
  const [numPages, setNumPages] = useState<number>();
  const [pageNumber, setPageNumber] = useState<number>(1);
  const [pdfBlob, setPdfBlob] = useState<Blob | null>(null);
  const [compiledFilename] = useState<string>("");
  const [compileResult, setCompileResult] = useState<CompileResult | null>(
    null,
  );
  const [showLogs, setShowLogs] = useState(false);

  const { mutateAsync, isPending } = useCompile();

  const handleCompile = async () => {
    try {
      if (!currentFileId) {
        throw new Error("No file selected");
      }

      const file = await downloadFileForCompilation(projectId, currentFileId);
      const result = await mutateAsync(file);

      setCompileResult(result);
      setShowLogs(false);

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
      } else {
        setPdfUrl(undefined);
        setPdfBlob(null);
      }
    } catch (error: unknown) {
      if (error instanceof AxiosError) {
        setCompileResult(error.response?.data || null);
        setPdfUrl(undefined);
        setPdfBlob(null);
        setShowLogs(true);
      }
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

  const renderLogContent = () => {
    if (!compileResult) return null;

    const isError = "error" in compileResult;
    const logContent = isError
      ? compileResult.error?.join("\n")
      : compileResult.log;

    return (
      <div className={`w-full h-full overflow-auto bg-white rounded-lg p-4`}>
        <pre
          className={`${isError ? "bg-red-100 text-red-900" : "bg-green-100 text-green-900"} p-3 rounded text-xs overflow-x-auto whitespace-pre-wrap`}
        >
          {logContent}
        </pre>
      </div>
    );
  };

  useEffect(() => {
    return () => {
      if (pdfUrl) {
        URL.revokeObjectURL(pdfUrl);
      }
    };
  }, [pdfUrl]);

  return (
    <section className="flex-1 bg-card px-4 rounded-lg flex flex-col h-full">
      <div className="flex-1 flex items-center justify-center min-h-0 my-4">
        {isPending && (
          <div className="text-center">
            <p>Compilando arquivo...</p>
          </div>
        )}

        {!isPending && showLogs && compileResult && renderLogContent()}

        {!isPending && !showLogs && pdfUrl && (
          <div className="w-full h-full overflow-auto flex justify-center border rounded-lg border-card">
            <div>
              <Document
                file={pdfUrl}
                onLoadSuccess={onDocumentLoadSuccess}
                loading={null}
              >
                <Page
                  pageNumber={pageNumber}
                  renderAnnotationLayer={false}
                  renderTextLayer={false}
                  loading={null}
                />
              </Document>
            </div>
          </div>
        )}

        {!isPending && !showLogs && !pdfUrl && (
          <div className="text-center">
            <p className="text-muted-foreground">
              {currentFileId
                ? `Clique em "Compilar" para gerar o PDF`
                : "Selecione um arquivo .tex para compilar"}
            </p>
          </div>
        )}
      </div>

      <div className="flex-shrink-0 pb-4 pt-4 flex justify-between">
        <div className="flex gap-2">
          <Button
            onClick={handleCompile}
            disabled={!currentFileId || isPending}
            className="cursor-pointer"
          >
            {isPending ? "Compilando..." : "Compilar"}
          </Button>
          {compileResult && (
            <>
              {pdfUrl && !showLogs && (
                <Button
                  onClick={handleDownloadPdf}
                  className="cursor-pointer"
                  variant="secondary"
                >
                  Baixar PDF
                </Button>
              )}
              <Button
                onClick={() => setShowLogs(!showLogs)}
                className="cursor-pointer border-white hover:bg-card/80 hover:text-white"
                variant="outline"
              >
                {showLogs ? "Ver PDF" : "Ver Logs"}
              </Button>
            </>
          )}
        </div>
        {pdfUrl && !showLogs && (
          <div className="flex gap-4 items-center">
            <p className="text-sm">
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
