import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class MapViewWidget extends StatefulWidget {
  final List<Map<String, dynamic>> servers;
  final Function(Map<String, dynamic>) onServerSelected;

  const MapViewWidget({
    Key? key,
    required this.servers,
    required this.onServerSelected,
  }) : super(key: key);

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    _markers = widget.servers.map((server) {
      return Marker(
        markerId: MarkerId(server['id'].toString()),
        position: LatLng(
          server['latitude'] as double,
          server['longitude'] as double,
        ),
        infoWindow: InfoWindow(
          title: server['city'] as String,
          snippet: '${server['country']} - ${server['ping']}ms',
          onTap: () => widget.onServerSelected(server),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerColor(server['load'] as String),
        ),
        onTap: () => _showServerInfo(server),
      );
    }).toSet();
  }

  double _getMarkerColor(String load) {
    switch (load.toLowerCase()) {
      case 'low':
        return BitmapDescriptor.hueGreen;
      case 'medium':
        return BitmapDescriptor.hueOrange;
      case 'high':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  void _showServerInfo(Map<String, dynamic> server) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 35.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 0.5,
                            ),
                          ),
                          child: CustomImageWidget(
                            imageUrl: server['flagUrl'] as String,
                            width: 12.w,
                            height: 8.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                server['city'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                server['country'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard(
                          context,
                          'Load',
                          server['load'] as String,
                          _getLoadColor(server['load'] as String),
                        ),
                        _buildInfoCard(
                          context,
                          'Ping',
                          '${server['ping']}ms',
                          _getPingColor(server['ping'] as int),
                        ),
                        _buildInfoCard(
                          context,
                          'Capacity',
                          '${server['capacity']}%',
                          Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onServerSelected(server);
                        },
                        child: const Text('Connect to Server'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Color _getLoadColor(String load) {
    switch (load.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Color _getPingColor(int ping) {
    if (ping < 50) return Colors.green;
    if (ping < 100) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(20.0, 0.0), // Center of world map
          zoom: 2.0,
        ),
        markers: _markers,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        mapToolbarEnabled: false,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
