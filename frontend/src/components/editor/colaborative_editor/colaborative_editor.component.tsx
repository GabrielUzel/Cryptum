"use client";

import { useEffect, useRef, useCallback } from "react";
import { useQuill } from "react-quilljs";
import "quill/dist/quill.snow.css";
import useDocumentChannel from "@/hooks/use-document-channel";
import Delta from "quill-delta";

interface ColaborativeEditorProps {
  fileId: string;
}

export default function ColaborativeEditor(props: ColaborativeEditorProps) {
  const { fileId } = props;
  const currentFileIdRef = useRef<string | null>(null);
  const disconnectRef = useRef<(() => void) | null>(null);
  const isInitialContentSetRef = useRef<boolean>(false);

  const { quill, quillRef } = useQuill({
    theme: "snow",
    modules: {
      toolbar: false,
    },
  });

  const updateLineNumbers = useCallback(() => {
    if (!lineNumbersRef.current || !quill) {
      return;
    }

    const text = quill.getText();
    const lines = text.split("\n");
    const numberOfLines = Math.max(1, lines.length - 1);

    lineNumbersRef.current.innerHTML = "";

    for (let i = 1; i <= numberOfLines; i++) {
      const div = document.createElement("div");
      div.textContent = i.toString();
      div.style.height = `20px`;
      div.style.lineHeight = `28px`;
      div.className = "text-white select-none text-right px-4";
      lineNumbersRef.current.appendChild(div);
    }
  }, [quill]);

  const applyContentToQuill = useCallback(
    (delta: Delta, kind: "open" | "update") => {
      if (!quill || currentFileIdRef.current !== fileId) {
        return;
      }

      if (kind === "open") {
        quill.setContents(delta, "silent");
        isInitialContentSetRef.current = true;
      } else {
        quill.updateContents(delta, "api");
      }

      updateLineNumbers();
    },
    [quill, fileId, updateLineNumbers],
  );

  const { connect, sendChange, canEdit } = useDocumentChannel(
    fileId,
    applyContentToQuill,
  );

  useEffect(() => {
    if (quill) {
      quill.enable(canEdit);
    }
  }, [quill, canEdit]);

  const lineNumbersRef = useRef<HTMLDivElement>(null);
  const editorWrapperRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!quill) {
      return;
    }

    const handleFileChange = async () => {
      if (currentFileIdRef.current !== fileId) {
        quill.setContents(new Delta(), "silent");
        isInitialContentSetRef.current = false;
        currentFileIdRef.current = fileId;

        if (disconnectRef.current) {
          disconnectRef.current();
          disconnectRef.current = null;
        }

        if (fileId) {
          const disconnect = await connect();
          disconnectRef.current = disconnect;
        }
      }
    };

    handleFileChange();

    return () => {
      if (currentFileIdRef.current === fileId) {
        if (disconnectRef.current) {
          disconnectRef.current();
          disconnectRef.current = null;
        }
        currentFileIdRef.current = null;
        isInitialContentSetRef.current = false;
      }

      if (quill) {
        quill.setContents(new Delta(), "silent");
      }
    };
  }, [fileId, quill, connect]);

  useEffect(() => {
    if (!quill || currentFileIdRef.current !== fileId) {
      return;
    }

    const handleTextChange = (
      delta: Delta,
      _oldDelta: Delta,
      source: "user" | "api" | "silent",
    ) => {
      if (source !== "user") {
        return;
      }

      if (currentFileIdRef.current === fileId) {
        sendChange(delta);
        updateLineNumbers();
      }
    };

    quill.on("text-change", handleTextChange);

    return () => {
      quill.off("text-change", handleTextChange);
    };
  }, [quill, sendChange, updateLineNumbers, fileId]);

  useEffect(() => {
    if (!lineNumbersRef.current || !editorWrapperRef.current) {
      return;
    }

    const handleScroll = () => {
      if (lineNumbersRef.current && editorWrapperRef.current) {
        lineNumbersRef.current.scrollTop = editorWrapperRef.current.scrollTop;
      }
    };

    const wrapper = editorWrapperRef.current;
    wrapper.addEventListener("scroll", handleScroll);

    return () => {
      wrapper.removeEventListener("scroll", handleScroll);
    };
  }, []);

  useEffect(() => {
    if (!quill) {
      return;
    }

    const container = quill.container;
    const editor = quill.root;

    container.style.cssText = `
      height: auto !important;
      min-height: 100% !important;
      border: none !important;
      font-family: monospace !important;
      overflow: visible !important;
    `;

    editor.style.cssText = `
      white-space: nowrap !important;
      overflow-wrap: normal !important;
      min-height: 100% !important;
      height: auto !important;
      padding: 8px 0px !important;
      line-height: 20px !important;
      font-family: monospace !important;
      color: black !important;
      overflow: visible !important;
    `;

    const applyLineStyles = (el: HTMLElement) => {
      el.style.cssText = `
        margin: 0 !important;
        padding: 0 0 0 4px !important;
        line-height: 20px !important;
        white-space: nowrap !important;
        color: black !important;
      `;
    };

    const initialElements = editor.querySelectorAll("p, pre, code, div");
    initialElements.forEach((el: Element) => {
      applyLineStyles(el as HTMLElement);
    });

    const observer = new MutationObserver((mutationsList) => {
      mutationsList.forEach((mutation) => {
        if (mutation.type === "childList") {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === 1) {
              const htmlEl = node as HTMLElement;
              if (!htmlEl.classList.contains("ql-editor")) {
                applyLineStyles(htmlEl);
              }
              htmlEl.querySelectorAll("p, pre, code, div").forEach((child) => {
                applyLineStyles(child as HTMLElement);
              });
            }
          });
        }
      });
    });

    const highlightCurrentLine = () => {
      const range = quill.getSelection();

      if (!range) {
        return;
      }

      const allLines = editor.querySelectorAll("p, pre, code, div");
      allLines.forEach((el) => {
        (el as HTMLElement).style.backgroundColor = "transparent";
      });

      const [line] = quill.getLine(range.index);

      if (!line) {
        return;
      }

      const lineDom = line.domNode as HTMLElement;
      lineDom.style.backgroundColor = "#a9b3bc";
    };

    quill.on("selection-change", highlightCurrentLine);
    quill.on("text-change", highlightCurrentLine);

    observer.observe(editor, { childList: true, subtree: true });
    updateLineNumbers();

    return () => {
      observer.disconnect();
    };
  }, [quill, updateLineNumbers]);

  return (
    <section className="flex-[2] bg-card p-4 rounded-lg flex flex-col h-full overflow-hidden">
      {!canEdit && (
        <div className="bg-yellow-500 text-white p-2 rounded text-center mb-2">
          Modo leitura
        </div>
      )}
      <div className="flex flex-1 min-h-0 overflow-hidden">
        <div
          ref={lineNumbersRef}
          className="bg-primary text-right select-none pt-1 flex flex-col justify-start overflow-y-hidden"
        />
        <div
          ref={editorWrapperRef}
          className="flex-1 min-w-0 bg-white overflow-auto text-black"
        >
          <div ref={quillRef} />
        </div>
      </div>
    </section>
  );
}
