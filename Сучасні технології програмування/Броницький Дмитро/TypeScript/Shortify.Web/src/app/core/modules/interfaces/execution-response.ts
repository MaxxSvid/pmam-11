export interface ExecutionResponse<T>{
    success: boolean;
    message: string;
    result: T;
}