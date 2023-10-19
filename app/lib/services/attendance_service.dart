import 'package:employee_flutter/constants/constants.dart';
import 'package:employee_flutter/models/attendance_model.dart';
import 'package:employee_flutter/services/location_service.dart';
import 'package:employee_flutter/utils/utilis.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
late GraphQLClient client;
class AttendanceService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  AttendanceModel? attendanceModel;

  String todayDate = DateFormat("dd MMMM yyyy").format(DateTime.now());

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
AttendanceService(){
   // Initialize the GraphQLClient here
    final HttpLink httpLink = HttpLink(
      'https://xjusozytdfhffhmijmdx.supabase.co/graphql/v1',
      defaultHeaders: <String, String>{
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhqdXNvenl0ZGZoZmZobWlqbWR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTMxNDA2MzUsImV4cCI6MjAwODcxNjYzNX0.jf0mRwzXJ51QuG7LGkAo7I3nzHxpzzWSEMLEfBLZbFA',
      },
    );

    client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
}
  String _attendanceHistoryMonth =
      DateFormat('MMMM yyyy').format(DateTime.now());

  String get attendanceHistoryMonth => _attendanceHistoryMonth;

  set attendanceHistoryMonth(String value) {
    _attendanceHistoryMonth = value;
    notifyListeners();
  }

  // Future getTodayAttendance() async {
  //   final List result = await _supabase
  //       .from(Constants.attendancetable)
  //       .select()
  //       .eq("employee_id", _supabase.auth.currentUser!.id)
  //       .eq('date', todayDate);
  //   if (result.isNotEmpty) {
  //     attendanceModel = AttendanceModel.fromJson(result.first);
  //   }
  //   notifyListeners();
  // }
Future<List<AttendanceModel>> getTodayAttendance() async {
    QueryOptions options = QueryOptions(
      document: gql('''
      query SelectAttendance(\$UserId: UUID, \$Date: StringFilter) {
        attendanceCollection(
          filter: {
            employee_id: {eq: \$UserId}
            date: {eq: \$Date}
          }
        ) {
          edges {
            node {
              id
              employee_id
              date
              check_in
              check_out
              created_at
            }
          }
        }
      }
    '''),
      variables: {
        'UserId': _supabase.auth.currentUser!.id,
        'Date': todayDate,
      },
    );
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      print(result.exception.toString());
      
      return [];
    } else {
      final data = result.data?['attendanceCollection']['edges'] ?? [];
      List<AttendanceModel> attendanceList = [];
      final edge= data[0];
        final id = edge['node']['id'];
        final date =
            edge['node']['date']; 
        final checkIn = 
            edge['node']['check_in'];
        final checkOut = 
            edge['node']['check_out'];
        final createdat = DateTime.parse(
            edge['node']['created_at']); 
        AttendanceModel attendance = AttendanceModel(
          id: id,
          date: date,
          checkIn: checkIn,
          checkOut: checkOut,
          createdAt: createdat,
        );
        attendanceList.add(attendance);
        print("rak m3allem");
      
      return attendanceList;
      
    }
  }


  Future markAttendance(BuildContext context) async {
    Map? getLocation =
        await LocationService().initializeAndGetLocation(context);
    print("Location Data :");
    print(getLocation);
    if (getLocation != null) {
      if (attendanceModel?.checkIn == null) {
        await _supabase.from(Constants.attendancetable).insert({
          'employee_id': _supabase.auth.currentUser!.id,
          'date': todayDate,
          'check_in': DateFormat('HH:mm').format(DateTime.now()),
          'check_in_location': getLocation,
        });
      } else if (attendanceModel?.checkOut == null) {
        await _supabase
            .from(Constants.attendancetable)
            .update({
              'check_out': DateFormat('HH:mm').format(DateTime.now()),
              'check_out_location': getLocation,
            })
            .eq('employee_id', _supabase.auth.currentUser!.id)
            .eq('date', todayDate);
      } else {
        Utils.showSnackBar("You have already checked out today !", context);
      }
      getTodayAttendance();
    } else {
      Utils.showSnackBar("Not able to get your Location", context,
          color: Colors.red);
      getTodayAttendance();
    }
  }

  Future<List<AttendanceModel>> getAttendanceHistory() async {
    final List data = await _supabase
        .from(Constants.attendancetable)
        .select()
        .eq('employee_id', _supabase.auth.currentUser!.id)
        .textSearch('date', "'$attendanceHistoryMonth'", config: 'english')
        .order('created_at', ascending: false);

    return data
        .map((attendance) => AttendanceModel.fromJson(attendance))
        .toList();
  }
}
