import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { environment } from "../../../../envirenments/environment.development";
import { Observable } from "rxjs";
import { ShortUrl } from "../interfaces/short-url";
import { ExecutionResponse } from "../interfaces/execution-response";
import { AddLinkRequestDTO } from "../interfaces/add-link-request-dto";
import { UrlInfo } from "../interfaces/url-info";

@Injectable({ providedIn: 'root' })
export class UrlService {
    apiUrl: string = environment.apiUrl;

  constructor(private http: HttpClient) {}

  getUrls(): Observable<ExecutionResponse<ShortUrl[]>> {
    return this.http.get<ExecutionResponse<ShortUrl[]>>(`${this.apiUrl}Link` , { withCredentials: true });
  }
  getUrlById(id: string): Observable<ExecutionResponse<UrlInfo>>{
    return this.http.get<ExecutionResponse<UrlInfo>>(`${this.apiUrl}Link/${id}`,{ withCredentials: true })
  }

  addUrl(originalUrl: AddLinkRequestDTO): Observable<ExecutionResponse<ShortUrl>> {
    return this.http.post<ExecutionResponse<ShortUrl>>(`${this.apiUrl}Link`, originalUrl, { withCredentials: true });
  }

  deleteUrl(id: string): Observable<ExecutionResponse<string>> {
      return this.http.delete<ExecutionResponse<string>>(`${this.apiUrl}Link/${id}`);
  }
}