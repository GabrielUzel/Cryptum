import { FilesGateway } from "@/api/files/files.gateway";
import { useQuery } from "@tanstack/react-query";

const filesGateway = new FilesGateway();

const fetchFiles = async (projectId: string) => {
  const data = await filesGateway.getFiles(projectId);
  return data;
};

export const getFilesQueryOptions = (projectId: string) => {
  return {
    queryKey: ['getFiles', projectId], 
    queryFn: () => fetchFiles(projectId), 
    retry: false,
    refetchInterval: 30000,
    refetchOnWindowFocus: false,
  };
};

export const useGetFiles = (projectId: string) => {
  return useQuery(getFilesQueryOptions(projectId));
}

export const createFile = async (projectId: string, filename: string) => {
  const data = await filesGateway.createFile(projectId, filename);
  return data;

}

export const downloadFile = async (projectId: string, filename: string) => {
  const data = await filesGateway.downloadFile(projectId, filename);
  return data;
}

export const updateFile = async (projectId: string, fileId: string, content: string) => {
  const data = await filesGateway.updateFile(projectId, fileId, content);
  return data;
}

export const renameFile = async (projectId: string, fileId: string, newFileName: string) => {
  const data = await filesGateway.renameFile(projectId, fileId, newFileName);
  return data;
}

export const deleteFile = async (projectId: string, fileId: string) => {
  const data = await filesGateway.deleteFile(projectId, fileId);
  return data;
}