  // protected async override void OnAppearing()
  //       {
  //           base.OnAppearing();
  //           PageService.CurrentPage = this;
  //           await Task.Run(() =>
  //           {
  //               //try
  //               //{
  //               //if(this.coreController.Car != null)
  //               //{
  //               this.nearestDeviceResolver.MonitoraggioSoloPiano = false;

  //               this.coreController.OnFloorChanged += CoreController_OnFloorChanged;
  //               this.coreController.OnMissionStatusChanged += CoreController_OnMissionStatusChanged;
  //               this.coreController.OnCharacteristicUpdated += CoreController_OnCharacteristicUpdated;



  //              Device.BeginInvokeOnMainThread(() =>
  //               {
  //                   try
  //                   {

                      
  //                       this.eta = Math.Abs(this.CurrentFloor - this.TargetFloor) * SECONDS_PER_FLOOR;
  //                       // this.currentPosition = this.direction == Direction.Up ? BOTTOM_Y : TOP_Y;

  //                       this.floor1Label.Text = this.coreController.CarDirection == Direction.Up ? $"{this.TargetFloor}" : $"{this.CurrentFloor}";
  //                       this.floor2Label.Text = this.coreController.CarDirection == Direction.Up ? $"{this.CurrentFloor}" : $"{this.TargetFloor}";
                        
  //                       if (this.coreController.CarDirection != Direction.Stopped)
  //                       {
  //                           this.directionIcon.Source = this.direction == Direction.Up ? "up.png" : "down.png";
  //                       }
  //                       else
  //                       {
  //                           this.directionIcon.Source = null;
  //                       }
  //                       this.elevatorIcon.TranslationY = this.currentPosition;
  //                       this.targetLabel.Text = $"ETA to floor {this.TargetFloor}";
  //                       int minuti = (int)Math.Floor((decimal)(this.coreController.Eta) / (int)60) + 2;
  //                       string tmp = Res.AppResources.TimeLeft + " " + minuti.ToString() + " ";
                       
  //                       if (minuti > 1) 
  //                       {
  //                          tmp +=Res.AppResources.Minuts;
  //                       }
  //                       else
  //                       {
  //                         tmp  +=Res.AppResources.Minut;
  //                       }
                        
  //                       this.etaLabel.Text = tmp;
  //                       // this.etaLabel.Text = $"{this.eta} sec";
  //                   }
  //                   catch (Exception)
  //                   {

  //                       throw;
  //                   }
  //               });
  //           });


  //           VisulizzaEventi();

            
  //       }