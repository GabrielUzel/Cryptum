"use client";

import { useEffect, useState, useRef, useCallback } from "react";
import { useParams } from "next/navigation";
import { useQuill } from "react-quilljs";
import "quill/dist/quill.snow.css";
import useDocumentChannel from "@/hooks/use-document-channel";
import Delta from "quill-delta";
import { updateFile } from "@/hooks/use-files";

interface ColaborativeEditorProps {
  fileId: string;
}

export default function ColaborativeEditor({ fileId }: ColaborativeEditorProps) {
  const params = useParams();
  const projectId = params.project_id as string;

  const [isConnected, setIsConnected] = useState(false);
  const [dirty, setDirty] = useState(false);
  const [content, setContent] = useState("");
  const { connect, sendChange } = useDocumentChannel(projectId, setContent);
  const { quill, quillRef } = useQuill({
    theme: "snow",
    modules: {
      toolbar: false
    },
  });

  const lineNumbersRef = useRef<HTMLDivElement>(null);
  const editorWrapperRef = useRef<HTMLDivElement>(null);

  const updateLineNumbers = useCallback(() => {
    if (!lineNumbersRef.current || !quill) {
      return;
    }

    const text = quill.getText();
    const lines = text.split('\n');
    const numberOfLines = Math.max(1, lines.length);
    
    lineNumbersRef.current.innerHTML = "";

    for (let i = 1; i <= numberOfLines; i++) {
      const div = document.createElement("div");
      div.textContent = i.toString();
      div.style.height = `20px`;
      div.style.lineHeight = `20px`;
      div.className = "text-white select-none text-right px-2";
      lineNumbersRef.current.appendChild(div);
    }
  }, [quill]);

  useEffect(() => {
    const disconnect = connect();
    setIsConnected(true);

    return () => {
      if (disconnect) disconnect();
    };
  }, [connect]);

  useEffect(() => {
    if (!quill) {
      return;
    }

    quill.setText(content);
    updateLineNumbers();
  }, [quill, content, updateLineNumbers]);

  useEffect(() => {
    if (!quill) {
      return;
    }

    const handleTextChange = (delta: Delta, oldDelta: Delta, source: "user" | "api" | "silent") => {
      if (source !== "user") {
        return;
      }
      
      setDirty(true);
      sendChange(quill.getContents().ops.map(op => op.insert).join(""));
      updateLineNumbers();
    };

    quill.on("text-change", handleTextChange);

    return () => {
      quill.off("text-change", handleTextChange);
    };
  }, [quill, sendChange, updateLineNumbers]);

  useEffect(() => {
    const interval = setInterval(async () => {
      if (!dirty || !quill) {
        return;
      }

      try {
        // await updateFile(projectId, fileId, quill.getText());
        setDirty(false);
      } catch (err) {
        console.error("Failed to auto-save:", err);
      }
    }, 5000);

    return () => clearInterval(interval);
  }, [dirty, quill, projectId, fileId]);

  useEffect(() => {
    if (!quill) {
      return;
    }

    updateLineNumbers();
  }, [quill, updateLineNumbers]);

  useEffect(() => {
    if (!lineNumbersRef.current || !editorWrapperRef.current) {
      return;
    }

    const handleScroll = () => {
      lineNumbersRef.current!.scrollTop = editorWrapperRef.current!.scrollTop;
    };

    const wrapper = editorWrapperRef.current;
    wrapper.addEventListener("scroll", handleScroll);
    return (
      () => wrapper.removeEventListener("scroll", handleScroll)
    );
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
      padding: 12px 15px !important;
      line-height: 20px !important;
      font-family: monospace !important;
      color: black !important;
      overflow: visible !important;
    `;

    const elements = editor.querySelectorAll('p, pre, code, div');
    elements.forEach((el: Element) => {
      const htmlEl = el as HTMLElement;
      htmlEl.style.cssText = `
        margin: 0 !important;
        padding: 0 !important;
        line-height: 20px !important;
        white-space: nowrap !important;
        color: black !important;
      `;
    });

    const observer = new MutationObserver(() => {
      const newElements = editor.querySelectorAll('p, pre, code, div');

      newElements.forEach((el: Element) => {
        const htmlEl = el as HTMLElement;
      
        if (!htmlEl.style.cssText.includes('white-space')) {
          htmlEl.style.cssText = `
            margin: 0 !important;
            padding: 0 !important;
            line-height: 20px !important;
            white-space: nowrap !important;
            color: black !important;
          `;
        }
      });
    });

    observer.observe(editor, { childList: true, subtree: true });
    updateLineNumbers();

    return () => observer.disconnect();
  }, [quill, updateLineNumbers]);

  return (
    <section className="flex-[2] bg-card p-4 rounded-lg flex flex-col h-full overflow-hidden">
      {!isConnected && (
        <p className="text-sm text-gray-400 mt-2">Conectando ao servidor...</p>
      )}
      <div className="flex flex-1 min-h-0 overflow-hidden">
        <div ref={lineNumbersRef} className="bg-primary text-right select-none p-2 flex flex-col overflow-y-hidden" />
        <div ref={editorWrapperRef} className="flex-1 min-w-0 bg-white overflow-auto text-black">
          <div ref={quillRef} />
        </div>
      </div>
    </section>
  );
}