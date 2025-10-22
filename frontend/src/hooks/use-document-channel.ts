"use client";

import { useRef, useState, useCallback, useEffect } from "react";
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
  setContent: (content: Delta) => void,
) {
  const socketRef = useRef<Socket | null>(null);
  const channelRef = useRef<Channel | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const versionRef = useRef<number>(0);
  const currentFileIdRef = useRef<string | null>(null);
  const cleanupRef = useRef<(() => void) | null>(null);

  const cleanupChannel = useCallback(async () => {
    if (channelRef.current) {
      const channel = channelRef.current;

      channel.off("open");
      channel.off("update");
      channel.off("close");

      return new Promise<void>((resolve) => {
        channel
          .leave()
          .receive("ok", () => resolve())
          .receive("error", () => resolve())
          .receive("timeout", () => resolve());

        setTimeout(resolve, 500);
      }).finally(() => {
        channelRef.current = null;
        setIsConnected(false);
      });
    }
  }, []);

  const connect = useCallback(async () => {
    if (currentFileIdRef.current === fileId && channelRef.current) {
      return () => {};
    }

    await cleanupChannel();

    versionRef.current = 0;
    currentFileIdRef.current = fileId;

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
      .receive("error", () => {
        setIsConnected(false);
      });

    const handleOpen = (payload: OpenPayload) => {
      if (currentFileIdRef.current === fileId) {
        versionRef.current = payload.version;

        const contentDelta =
          payload.content && payload.content.ops
            ? new Delta(payload.content)
            : new Delta();
        setContent(contentDelta);
      }
    };

    const handleUpdate = (payload: UpdatePayload) => {
      if (currentFileIdRef.current === fileId) {
        versionRef.current = payload.version;

        const changeDelta =
          payload.change && payload.change.ops
            ? new Delta(payload.change)
            : new Delta();
        setContent(changeDelta);
      }
    };

    channel.on("open", handleOpen);
    channel.on("update", handleUpdate);

    const specificCleanup = async () => {
      if (currentFileIdRef.current === fileId) {
        await cleanupChannel();

        if (socketRef.current) {
          socketRef.current.disconnect();
          socketRef.current = null;
        }

        currentFileIdRef.current = null;
      }
    };

    cleanupRef.current = specificCleanup;
    return specificCleanup;
  }, [fileId, setContent, cleanupChannel]);

  const sendChange = (delta: Delta) => {
    if (
      channelRef.current &&
      isConnected &&
      currentFileIdRef.current === fileId
    ) {
      channelRef.current
        .push("update", {
          change: delta,
          version: versionRef.current,
        })
        .receive("ok", (resp: { version: number }) => {
          versionRef.current = resp.version;
        })
        .receive("error", () => {});
    }
  };

  useEffect(() => {
    return () => {
      if (cleanupRef.current) {
        cleanupRef.current();
      }
    };
  }, []);

  return { connect, sendChange, isConnected };
}
