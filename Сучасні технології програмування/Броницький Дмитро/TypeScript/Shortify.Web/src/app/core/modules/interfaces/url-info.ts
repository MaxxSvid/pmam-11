import { ShortUrl } from "./short-url";

export interface UrlInfo extends ShortUrl{
    updatedBy?: string;
    updatedAt?: string;
    title: string;
    description: string;  
}