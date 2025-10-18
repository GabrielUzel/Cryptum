// use-document-channel.ts

import { useRef, useState, useCallback } from "react";
import { Socket, Channel } from "phoenix";
import { createSocket } from "@/utils/socket";
import Delta from "quill-delta";

interface UpdatePayload {
  change: Delta;
  version: number;
}

interface OpenPayload {
  content: Delta;
  version: number;
}

export default function useDocumentChannel(
  fileId: string,
  setContent: (content: Delta) => void
) {
  const socketRef = useRef<Socket | null>(null);
  const channelRef = useRef<Channel | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const versionRef = useRef<number>(0);

  const connect = useCallback(() => {
    const socket = createSocket();
    socketRef.current = socket;

    const channel = socket.channel(`document:${fileId}`, {});
    channelRef.current = channel;

    channel
      .join()
      .receive("ok", (resp) => {
        setIsConnected(true);
        if (resp.version) {
            versionRef.current = resp.version;
        }
      })
      .receive("error", (resp) => {
        console.error("Erro ao conectar ao canal:", resp);
      });

    channel.on("open", (payload: OpenPayload) => {
      versionRef.current = payload.version;
      setContent(new Delta(payload.content));
    });

    channel.on("update", (payload: UpdatePayload) => {
      versionRef.current = payload.version;
      setContent(new Delta(payload.change));
    });

    // CORREÇÃO: Usa os refs para garantir o leave/disconnect da instância atual
    return () => {
      if (channelRef.current) {
        channelRef.current.leave();
        channelRef.current = null;
      }
      if (socketRef.current) {
        socketRef.current.disconnect();
        socketRef.current = null;
      }
      setIsConnected(false);
    };
  }, [fileId, setContent]);

  const sendChange = (delta: Delta) => {
    if (channelRef.current && isConnected) {
      channelRef.current.push("update", { 
          change: delta, 
          version: versionRef.current 
        })
        .receive("ok", (resp: { version: number }) => {
            versionRef.current = resp.version;
        })
        .receive("error", (resp) => {
            console.error("Erro ao enviar Delta:", resp);
        });
    }
  };

  return { connect, sendChange, isConnected };
}