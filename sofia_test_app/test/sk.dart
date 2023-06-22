//  private async void Refresh()
//         {
            

//             // recupero piano di destinazione frequente
//             string targetFloor = "";

            

//             if (this.coreController.Devices.Count == 0)
//             {
//                 Device.BeginInvokeOnMainThread(() =>
//                 {
//                     Wait.IsVisible = true;
//                     GrigliaFromTo.IsVisible = false;
                    
                  
//                 });
//                 return;
//             }

//             if (this.coreController.NearestDevice != null)
//             {
                

//                 targetFloor = await GetTargetFloorAsync(this.coreController.NearestDevice.Alias);

//                 Device.BeginInvokeOnMainThread(() =>
//                 {
//                     if (this.coreController.OutOfService == true)
//                     {
//                         Wait.IsVisible = false;
//                         GrigliaFromTo.IsVisible = true;
                        
//                         // Debug.Print("************ Fuori servizio !!!! ***********");
//                         //this.coreController.Get_Piano_Cabina();
//                         TestoErrore.Text = Res.AppResources.ElevatorOutOfOrder;
                        
//                         if (coreController.CarDirection == Direction.Up )
//                         {
//                             PosizioneCabina.Text = String.Format(Res.AppResources.LocationCabinBetween,coreController.CarFloor, (coreController.CarFloorNum + 1).ToString());
//                         }
//                         else if(coreController.CarDirection == Direction.Down)
//                         {
//                             PosizioneCabina.Text = String.Format(Res.AppResources.LocationCabinBetween, coreController.CarFloor, (coreController.CarFloorNum - 1).ToString());
//                         }
//                         else if(coreController.CarDirection == Direction.Stopped)
//                         {
//                             PosizioneCabina.Text = Res.AppResources.LocationCabin + " " + coreController.CarFloor;
//                         }
//                         TestoErrore.IsVisible = true;
//                         PosizioneCabina.IsVisible = true;
//                     }
//                     else
//                     {
//                         TestoErrore.IsVisible = false;
//                         PosizioneCabina.IsVisible = false;
//                     }
//                 });


//             }


//             if (LuceMancante == false)
//             {
//                 if (this.coreController.PresenceOfLight == false)
//                 {
//                     SecondiPassati = ((DateTime.Now.Ticks - tickAttuali) / TimeSpan.TicksPerSecond);
//                     Debug.Print("secondi:");
//                     Debug.Print(SecondiPassati.ToString());
//                     if ((SecondiPassati > IntervalloMessaggioLuceAssente) || (PrimaConnessioneDevice == true))
//                     {
//                         PrimaConnessioneDevice = false;
//                         Device.BeginInvokeOnMainThread(async () =>
//                         {
//                             this.TestoLuce.IsVisible = true;                           

//                             //await DisplayAlert("Info", Res.AppResources.AttentionLackOfLight, "Ok");
                            
//                         });

//                         // Debug.Print("************ Luce mancante !!!! ***********");
//                         LuceMancante = true;
//                         tickAttuali = DateTime.Now.Ticks;
//                     }
//                 }
//             }

//             if (LuceMancante == true)
//             {
//                 if (this.coreController.PresenceOfLight == true)
//                 {
//                     LuceMancante = false;
//                     Device.BeginInvokeOnMainThread(() =>
//                     {
//                         this.TestoLuce.IsVisible = false;
//                     });
//                     Debug.Print("************ Luce presente !!!! ***********");
                    
//                 }
//             }




       
//             Device.BeginInvokeOnMainThread(() =>
//             {
//                                    if (IsFloor(this.coreController.NearestDevice))
//                                    {
//                                        Wait.IsVisible = false;
//                                        GrigliaFromTo.IsVisible = true;
                                       
//                                        if (this.coreController.NearestDevice.Alias != FloorPrecedente)
//                                        {
//                                            if (Device.RuntimePlatform == Device.iOS) 
//                                            { 
//                                                this.confirmButton.IsVisible = true; 
//                                            }
                                           
//                                            this.welcomeLabel.Text = String.Format(Res.AppResources.WelcomeText, coreController.LoggerUser.Username, Environment.NewLine);                                           
//                                            this.FromFloor.Text = Res.AppResources.From;
//                                            this.ToFloor.Text = Res.AppResources.To;
//                                            this.currentFloorLabel.Text = this.coreController.NearestDevice.Alias;
//                                            this.confirmButton.IsEnabled = true;
//                                            this.floorSelectorEntry.IsEnabled = true;
//                                            this.floorSelectorEntry.Text = targetFloor;
//                                            //this.floorSelectorEntry.Focus();
//                                            FloorPrecedente = this.coreController.NearestDevice.Alias;
//                                        }
//                                        else
//                                        {
//                                            this.floorSelectorEntry.IsEnabled = true;
//                                            //this.floorSelectorEntry.Focus();
//                                            this.confirmButton.IsEnabled = true;
//                                        }

//                                    }
//                                    else
//                                    {
//                                        Wait.IsVisible = true;
//                                        GrigliaFromTo.IsVisible = false;
                                    
//                                    }
//                                });

            
//         }