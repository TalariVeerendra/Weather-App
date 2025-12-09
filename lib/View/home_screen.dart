import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weatherpredication/Provider/theme_provider.dart';
import 'package:weatherpredication/Service/api_service.dart';
import 'package:weatherpredication/View/weekly_forecast.dart';

class WeatherAppHomeScreen extends ConsumerStatefulWidget {
  const WeatherAppHomeScreen({super.key});

  @override
  ConsumerState<WeatherAppHomeScreen> createState() => _WeatherAppHomeScreenState();
}

class _WeatherAppHomeScreenState extends ConsumerState<WeatherAppHomeScreen> {
  final _weatherService = WeatherApiService();
  String city = "Hyderabad"; //Initially Location
  String country = '';
  Map<String, dynamic> currentValue = {};
  List<dynamic> hourly = [];
  List<dynamic> pastWeek = [];
  List<dynamic> next7days = [];
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }
  
  Future<void> _fetchWeather() async{
    setState(() {
      isLoading = true;
    });
    try{
      final forecast = await _weatherService.getHourlyForecast(city);
      final past = await _weatherService.getPastSevenDaysWeather(city);
      
      setState(() {
        currentValue = forecast['current']??{};
        hourly = forecast['forecast']?['forecastday']?[0]?['hour']??[];
        
        // fore next 7 days
        next7days =  forecast['forecast']?['forecastday']??[];
        pastWeek = past;
        city= forecast['location']?['name']?? city;
        country =  forecast['location']?['country']??'';
        isLoading = false;
      });
      
    }catch(e){
      setState(() {
        currentValue={};
        hourly=[];
        pastWeek=[];
        next7days=[];
        isLoading=false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("City not found"
        ),
        ),
      );
    }
    
  }

  String formateTime(String timeString){
    DateTime time = DateTime.parse(timeString);
    return DateFormat.j().format(time);
  }
  
  
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    String iconPath = currentValue['condition']?['icon']??'';
    String imageUrl = iconPath.isNotEmpty?"http:$iconPath":"";

    Widget imageWidgets =
    imageUrl.isNotEmpty?
    Image.network(
      imageUrl,
      height: 200,
      width: 200,
      fit: BoxFit.cover,
    ):
    SizedBox();
    return Scaffold(
      backgroundColor:  Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          SizedBox(width: 25,),
          SizedBox(width: 280,height: 50,
            child: TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
              onSubmitted: (value){
                if(value.trim().isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please Enter city name"
                    ),
                    ),
                  );
                  return;
                }
                city = value.trim();
                _fetchWeather();
              },
            decoration: InputDecoration(
              labelText: "Search City",
              prefixIcon: Icon(Icons.search,color: Theme.of(context).colorScheme.surface,),
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.surface,),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface,),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.surface,),
              )
            ),
          ),),Spacer(),
          GestureDetector(
            onTap: notifier.toggleTheme,
            child: Icon(isDark? Icons.light_mode: Icons.light_mode,
            color: isDark? Colors.black:Colors.white,size: 30,
            ),

          ),
          SizedBox(width: 25,),

        ],


      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            if(isLoading) const Center(child: CircularProgressIndicator(),)
            
            else...[
              if(currentValue.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  Text("$city${country.isNotEmpty ? ',$country' : ''}",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 40,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w400,
                  ),  
                  ),
                    Text("${currentValue["temp_c"]}°C",
                      style: TextStyle(
                        fontSize: 50,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("${currentValue['condition']['text']}",
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    imageWidgets,
                    Padding(padding: EdgeInsets.all(15),
                      child: Container(
                        height: 80,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary,
                              offset: Offset(1,1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                          borderRadius: BorderRadius.circular(30),
        
        
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // For Humidity
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Image.network("https://cdn-icons-png.flaticon.com/512/4148/4148460.png",width: 30,height: 30,),
                              Text("${currentValue['humidity']}%",
                                style:TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
        
                                ) ,
                              ),
                              Text("Humidity",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
        
                                ),
                              )
                            ],
                            ),
                            //FOR Wind
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Image.network("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-o7Nm93dm8PKp-P0MMuxoy1EIq091E_tji1MaB7dkXVezymmOaTFfug01vv3qB1zvUBQ&usqp=CAU",width: 30,height: 30,),
                              Text("${currentValue['wind_kph']} kph",
                                style:TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
        
                                ) ,
                              ),
                              Text("Wind",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
        
                                ),
                              )
                            ],
                            ),
                            // for max temparature
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Image.network("https://static.vecteezy.com/system/resources/thumbnails/007/139/826/small_2x/temperature-thermometer-icon-free-vector.jpg",width: 30,height: 30,),
                              Text(
                                "${hourly.isNotEmpty ? hourly.map((h)=> h['temp_c']).reduce((a,b)=> a>b?a:b):"N/A"}",
                                style:TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
        
                                ) ,
                              ),
                              Text("Temp",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
        
                                ),
                              )
                            ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),
                    Container(
                      height: 250,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
        
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20,vertical: 10
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Today Forecast",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder:
                                                (context) => WeeklyForecast(
                                                  city: city,
                                                  currentValue: currentValue,
                                                  pastWeek: pastWeek,
                                                  next7days: next7days,
        
                                                ),
                                        ),
                                    );
        
                                  },
                                  child:  Text("Weekly Forecast",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(color: Theme.of(context).colorScheme.secondary,),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(height: 155,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hourly.length,
        
                            itemBuilder: (context, index){
                              final hour = hourly[index];
                              final now = DateTime.now();
                              final hourTime = DateTime.parse(hour['time']);
                              final isCurrentHour = now.hour == hourTime.hour && now.day == hourTime.day;
                              return Padding(padding: EdgeInsets.all(8),
                                child: Container(
                                  height: 70,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCurrentHour ? Colors.orangeAccent: Colors.black38,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        isCurrentHour
                                            ? "Now"
                                            : formateTime(hour['time']),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Image.network("https:${hour['condition']?['icon']}",
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(height: 10,),
                                      Text("${hour["temp_c"]}°C",
                                        style: TextStyle(
                                          color:  Theme.of(context).colorScheme.secondary,
                                          fontWeight: FontWeight.w500,
        
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ]
          ],
        ),
      ),
    );
  }
}
