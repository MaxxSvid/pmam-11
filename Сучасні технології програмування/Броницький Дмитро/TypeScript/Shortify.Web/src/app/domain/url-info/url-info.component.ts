import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { UrlService } from '../../core/modules/services/url-service';
import { CommonModule } from '@angular/common';
import { UserService } from '../../core/modules/services/user-service';
import { UserInfoDTO } from '../../core/modules/interfaces/user-info';
import { RedirectService } from '../../core/modules/services/redirect-service';

@Component({
  selector: 'app-url-info',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './url-info.component.html',
  styleUrls: ['./url-info.component.css']
})
export class UrlInfoComponent {
  urlInfo: any;
  userInfo: UserInfoDTO = { id: ' ', userName: ' ', email: ' ' };

  constructor(private route: ActivatedRoute,
    private urlService: UrlService,
    private userService: UserService,
    private redirectService: RedirectService) { }

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.urlService.getUrlById(id).subscribe({
        next: response => {
          if (response.success && response.result) {
            this.urlInfo = response.result;

            this.userService.getUser(this.urlInfo.createdBy).subscribe({
              next: userResp => {
                if (userResp.success && userResp.result) {
                  this.userInfo = userResp.result;
                }
              },
              error: err => console.error(err)
            });

          } else {
            console.error(response.message);
          }
        },
        error: err => console.error(err)
      });
    }
  }

  viewOriginal(urlId: string) {
    this.redirectService.redirectToOriginal(urlId, true);
  }

}
