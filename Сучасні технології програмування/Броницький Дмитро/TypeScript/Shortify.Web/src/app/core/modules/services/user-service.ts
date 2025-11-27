import { HttpClient } from "@angular/common/http";
import { environment } from "../../../../envirenments/environment.development";
import { Observable } from "rxjs";
import { ExecutionResponse } from "../interfaces/execution-response";
import { UserInfoDTO } from "../interfaces/user-info";
import { Injectable } from "@angular/core";

@Injectable({
  providedIn: 'root'
})
export class UserService {
    apiUrl: string = environment.apiUrl;

    constructor(
        private http: HttpClient,
    ) { }

    getUser(id: string): Observable<ExecutionResponse<UserInfoDTO>>{
        return this.http.get<ExecutionResponse<UserInfoDTO>>(`${this.apiUrl}User/${id}` , {withCredentials: true})
    }

}