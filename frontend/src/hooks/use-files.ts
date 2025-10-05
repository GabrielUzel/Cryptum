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
  try {
    const data = await filesGateway.createFile(projectId, filename);
    return data;
  } catch (error) {
    throw error;
  }
}

export const downloadFile = async (projectId: string, filename: string) => {
  try {
    const data = await filesGateway.downloadFile(projectId, filename);
    return data;
  } catch (error) {
    throw error;
  }
}

export const updateFile = async (projectId: string, fileId: string, content: string) => {
  try {
    const data = await filesGateway.updateFile(projectId, fileId, content);
    return data;
  } catch (error) {
    throw error;
  }
}

export const renameFile = async (projectId: string, fileId: string, newFileName: string) => {
  try {
    const data = await filesGateway.renameFile(projectId, fileId, newFileName);
    return data;
  } catch (error) {
    throw error;
  }
}

export const deleteFile = async (projectId: string, fileId: string) => {
  try {
    const data = await filesGateway.deleteFile(projectId, fileId);
    return data;
  } catch (error) {
    throw error;
  }
}