import 'package:flutter/material.dart';
import '../../../../widgets/app_logo_header.dart';

class AlarmTab extends StatelessWidget {
  const AlarmTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft),
          AppLogoHeader(),
          SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,

            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnnouncementCard(title: "귀가버스 차량 정보", date: "이미지보기"),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String date;

  const AnnouncementCard({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [], // 필요 시 그림자 추가
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title,style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 6),
                        Text(date),
                      ],
                      
                    ),
                    Text("26.12.30")
                  ],
                ),
              ]
            ),
          ),
        ),
        
      ],
    );
  }
}
