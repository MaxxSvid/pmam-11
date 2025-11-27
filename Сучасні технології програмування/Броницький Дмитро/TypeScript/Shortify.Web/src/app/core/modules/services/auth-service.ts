import { Injectable } from "@angular/core";
import { environment } from "../../../../envirenments/environment.development";
import { HttpClient } from "@angular/common/http";
import { LoginRequestDTO } from "../interfaces/login-request-dto";
import { Observable, tap } from "rxjs";
import { ExecutionResponse } from "../interfaces/execution-response";
import { AuthResponseDTO } from "../interfaces/auth-response-dto";
import { RegistrationRequestDTO } from "../interfaces/registration-request-dto";
import { TokenDecoderService } from "./token-decoder-service";
import { User } from "../interfaces/user.model";
import { clearUser, setUser } from "./user.actions";
import { Store } from "@ngrx/store";


@Injectable({
    providedIn: 'root'
})
export class AuthService {
    apiUrl: string = environment.apiUrl;

    constructor(
        private http: HttpClient,
        private tokenDecoder: TokenDecoderService,
        private store: Store
    ) { }

    login(data: LoginRequestDTO): Observable<ExecutionResponse<AuthResponseDTO>> {
        return this.http.post<ExecutionResponse<AuthResponseDTO>>(`${this.apiUrl}Auth/login`, data, {
            withCredentials: true
        }).pipe(
            tap((response) => {
                if (response.success) {
                    this.setAccessToken(response.result.accessToken);
                    const user: User = {
                        id: response.result.userId,
                        email: response.result.email,
                        role: response.result.role,
                        userName: response.result.userName
                    };
                    this.store.dispatch(setUser({ user }));
                }
            })
        );
    }

    register(data: RegistrationRequestDTO): Observable<ExecutionResponse<AuthResponseDTO>> {
        return this.http.post<ExecutionResponse<AuthResponseDTO>>(`${this.apiUrl}Auth/register`, data, {
            withCredentials: true
        }).pipe(
            tap((response) => {
                if (response.success) {
                    this.setAccessToken(response.result.accessToken);
                    const user: User = {
                        id: response.result.userId,
                        email: response.result.email,
                        role: response.result.role,
                        userName: response.result.userName
                    };
                    this.store.dispatch(setUser({ user }));
                }
            })
        );
    }

    refreshToken(): Observable<ExecutionResponse<AuthResponseDTO>> {
        const accessToken = this.getAccessToken();
        if (!accessToken) throw new Error('No access token');

        return this.http.post<ExecutionResponse<AuthResponseDTO>>(`${this.apiUrl}Auth/refresh`, { accessToken }, {
            withCredentials: true
        }).pipe(
            tap((response) => {
                if (response.success) {
                    this.setAccessToken(response.result.accessToken);
                    const decoded = this.tokenDecoder.decodeToken(response.result.accessToken);
                    if (decoded) {
                        const user: User = {
                        id: response.result.userId,
                        email: response.result.email,
                        role: response.result.role,
                        userName: response.result.userName
                        };
                        this.store.dispatch(setUser({ user }));
                    }
                }
            })
        );
    }
    private setAccessToken(accessToken: string) {
        localStorage.setItem('accessToken', accessToken);
    }

    getAccessToken(): string | null {
        return localStorage.getItem('accessToken');
    }

    private clearAccessToken() {
        localStorage.removeItem('accessToken');
    }
    logout() {
        localStorage.removeItem('accessToken');
        this.store.dispatch(clearUser());
    }
}